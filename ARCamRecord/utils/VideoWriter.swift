//
//  VideoWriter.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import AVFoundation
import Foundation

public class VideoWriter: ObservableObject {
    @Published public var latestPixelBuffer: CVPixelBuffer? = nil

    var width: Int = 400
    var height: Int = 400

    var frameTime: Double = 1.0 {
        didSet { frameRate = CMTime(seconds: frameTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) }
    }

    var url: URL? = nil
    var backPressure: Int = 32

    private var frameRate: CMTime = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

    let writerQueue: DispatchQueue
    let writerCondition: NSCondition
    var writerSemaphore: DispatchSemaphore

    var writer: AVAssetWriter!
    var writerInput: AVAssetWriterInput!
    var writerAdaptor: AVAssetWriterInputPixelBufferAdaptor!

    var writerObservation: NSKeyValueObservation!

    var currentFrameTime = CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

    public init() {
        writerQueue = DispatchQueue(label: "us.gerstacker.adventofcode.animator")
        writerCondition = NSCondition()
        writerSemaphore = DispatchSemaphore(value: backPressure)
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
        
        let sourceAttributes: [String:Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA),
            String(kCVPixelBufferMetalCompatibilityKey) : NSNumber(value: true)
        ]

        writerAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceAttributes)

        if writer.canAdd(writerInput) {
            writer.add(writerInput)
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
    }
}
