//
//  VideoWriter.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import AVFoundation
import Foundation

public class VideoWriter: NSObject, ObservableObject {
    @Published public var latestPixelBuffer: CVPixelBuffer? = nil

    var width: Int = 400
    var height: Int = 400
    
    var queueLabel = "video.recording"

    var frameTime: Double = 1.0 {
        didSet { frameRate = CMTime(seconds: frameTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) }
    }

    var url: URL? = nil
    var backPressure: Int = 32

    private var frameRate: CMTime = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

    let writerQueue: DispatchQueue
    let writerCondition: NSCondition
    var writerSemaphore: DispatchSemaphore
    var pixelFormatType = kCVPixelFormatType_32BGRA

    var writer: AVAssetWriter!
    var writerInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    var writerAdaptor: AVAssetWriterInputPixelBufferAdaptor!

    var writerObservation: NSKeyValueObservation!

    var currentFrameTime = CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

    var captureSession: AVCaptureSession?
    var micInput: AVCaptureDeviceInput?
    var audioOutput: AVCaptureAudioDataOutput?
    
    public override init() {
        writerQueue = DispatchQueue(label: queueLabel)
        writerCondition = NSCondition()
        writerSemaphore = DispatchSemaphore(value: backPressure)
        super.init()
    }

    public func complete() {
        writerQueue.sync {
            writerInput.markAsFinished()
        }

        let condition = NSCondition()
        var complete = false

        writer.finishWriting {
            if self.writer.status == .failed {
                let message = self.writer.error?.localizedDescription ?? "UNKNOWN"
                print("Failed to finish writing: \(message)")
            }

            condition.lock()
            complete = true
            condition.signal()
            condition.unlock()
        }

        condition.lock()

        while !complete {
            condition.wait()
        }

        condition.unlock()

        writerObservation.invalidate()
        endAudioRecording()
    }
    
    func submit(pixelBuffer: CVPixelBuffer) {
        writerSemaphore.wait()

        writerQueue.async {
            self.writerCondition.lock()

            while !self.writerInput.isReadyForMoreMediaData {
                self.writerCondition.wait()
            }
            
            self.writerCondition.unlock()
            
            self.writerAdaptor.append(pixelBuffer, withPresentationTime: self.currentFrameTime)
            self.currentFrameTime = CMTimeAdd(self.currentFrameTime, self.frameRate)
            
            self.writerSemaphore.signal()
        }
    }

    public func start() {
        precondition(width % 2 == 0)
        precondition(height % 2 == 0)
        precondition(url != nil)
        
        if FileManager.default.fileExists(atPath: url!.path) {
            try! FileManager.default.removeItem(at: url!)
        }

        writer = try! AVAssetWriter(url: url!, fileType: .mov)
        
        let videoSettings: [String:Any] = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoWidthKey: NSNumber(value: width),
            AVVideoHeightKey: NSNumber(value:height),
        ]

        writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        
        let audioOutputSettings = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.0,
            AVEncoderBitRateKey: 192000
            ] as [String : Any]
        
        audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings);
        audioInput.expectsMediaDataInRealTime = true
        
        let sourceAttributes: [String:Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: pixelFormatType),
            String(kCVPixelBufferMetalCompatibilityKey) : NSNumber(value: true)
        ]

        writerAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceAttributes)

        if writer.canAdd(writerInput) {
            writer.add(writerInput)
            writer.add(audioInput);
        } else {
            fatalError("Could not add writer input")
        }

        guard writer.startWriting() else {
            let message = writer.error?.localizedDescription ?? "UNKNOWN"
            fatalError("Could not start writing: \(message)")
        }
        
        writer.startSession(atSourceTime: currentFrameTime)
        
        writerSemaphore = DispatchSemaphore(value: backPressure)

        writerObservation = writerInput.observe(\.isReadyForMoreMediaData, options: .new, changeHandler: { (_, change) in
            guard let isReady = change.newValue else {
                return
            }

            if isReady {
                self.writerCondition.lock()
                self.writerCondition.signal()
                self.writerCondition.unlock()
            }
        })
        
        startAudioRecording()
    }
     
    func startAudioRecording() {
        
        let microphone = AVCaptureDevice.default(.microphone, for: AVMediaType.audio, position: .unspecified)
        
        do {
            try self.micInput = AVCaptureDeviceInput(device: microphone!);
            
            self.captureSession = AVCaptureSession();
            
            if (self.captureSession?.canAddInput(self.micInput!))! {
                self.captureSession?.addInput(self.micInput!);
                
                self.audioOutput = AVCaptureAudioDataOutput();
                
                if self.captureSession!.canAddOutput(self.audioOutput!){
                    self.captureSession!.addOutput(self.audioOutput!)
                    self.audioOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.global());
                    
                    self.captureSession?.startRunning();
                }
                
            }
        }
        catch {
            print("Failed to start audio session \(error.localizedDescription)")
        }
    }
    
    func endAudioRecording() {
        captureSession!.stopRunning();
    }

}

extension VideoWriter: AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var count: CMItemCount = 0
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: 0, arrayToFill: nil, entriesNeededOut: &count);
        var info = [CMSampleTimingInfo](repeating: CMSampleTimingInfo(duration: CMTimeMake(value: 0, timescale: 0), presentationTimeStamp: CMTimeMake(value: 0, timescale: 0), decodeTimeStamp: CMTimeMake(value: 0, timescale: 0)), count: count)
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: count, arrayToFill: &info, entriesNeededOut: &count);
        
        for i in 0..<count {
            info[i].decodeTimeStamp = self.currentFrameTime
            info[i].presentationTimeStamp = self.currentFrameTime
        }

        var soundbuffer: CMSampleBuffer?
        
        CMSampleBufferCreateCopyWithNewTiming(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleTimingEntryCount: count, sampleTimingArray: &info, sampleBufferOut: &soundbuffer);
        

        audioInput.append(soundbuffer!);
    }
}
