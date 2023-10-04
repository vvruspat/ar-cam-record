//
//  ARManager.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 24/09/2023.
//

import RealityKit
import SceneKit
import ARKit
import CoreVideo
import SwiftUI

class ARManager: NSObject, ObservableObject {

    var planes = [UUID: PlaneAnchorEntity]()

    static let shared = ARManager()
    
    let arView: ARView
    var cameraTransforms: Array<float4x4> = []
    
    var timer: Timer?
    var counter = 0
    var timeStart: TimeInterval?
    
    var fps: Float = 30.0
    var videoWriter: VideoWriter?
    var lidarWriter: VideoWriter?
    
    var filename = "ar-captured"
    
    @Published var isRecording = false
    @AppStorage(SettingsKeys.showLidar) var showLidar = false
    @AppStorage(SettingsKeys.recordLidar) var recordLidar = false
    
    override init() {
        arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false

        super.init()
        
        let config = ARWorldTrackingConfiguration()
            
        if let hiResFormat = ARWorldTrackingConfiguration.recommendedVideoFormatFor4KResolution {
            print("hiRes")
            config.videoFormat = hiResFormat
        }
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            print("sceneDepth")
            config.frameSemantics = .sceneDepth
        }
        
        config.sceneReconstruction = .meshWithClassification
        config.planeDetection = [.horizontal/*, .vertical*/]
                
        if (showLidar) {
            arView.debugOptions.insert(.showSceneUnderstanding)
        }
        
        UserDefaults.standard.addObserver(self, forKeyPath: SettingsKeys.showLidar, options: .new, context: nil)

        arView.session.run(config)
        
        fps = Float(config.videoFormat.framesPerSecond)

        arView.session.delegate = self
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: SettingsKeys.showLidar)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if showLidar {
           self.arView.debugOptions.insert(.showSceneUnderstanding)
        } else {
           self.arView.debugOptions.remove(.showSceneUnderstanding)
        }
    }
    
    func record () async {
        let session = await self.arView.session
        self.filename = "ar-captured-\(Int(Date.now.timeIntervalSince1970))"
        
        videoWriter = VideoWriter()
        videoWriter?.frameTime = Double(1.0 / self.fps)
        videoWriter?.width = Int(session.configuration?.videoFormat.imageResolution.width ?? 3840.0)
        videoWriter?.height = Int(session.configuration?.videoFormat.imageResolution.height ?? 2160.0)
        videoWriter?.url = self.getPathToSave("\(self.filename).mov")
        videoWriter?.start()
        
        if recordLidar {
            lidarWriter = VideoWriter()
            lidarWriter?.queueLabel = "lidar.recording"
            lidarWriter?.frameTime = Double(1.0 / self.fps)
            lidarWriter?.width = Int(session.configuration?.videoFormat.imageResolution.width ?? 3840.0)
            lidarWriter?.height = Int(session.configuration?.videoFormat.imageResolution.height ?? 2160.0)
            lidarWriter?.url = self.getPathToSave("\(self.filename)-lidar.mov")
            lidarWriter?.start()
        } else {
            lidarWriter = nil
        }
        
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        self.isRecording = false
        videoWriter?.complete();
        lidarWriter?.complete();
        self.saveSCNFileToDisk()
    }
    
    func getDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first
    }
    
    func getPathToSave(_ fileName: String) -> URL? {
        return getDirectory()?.appendingPathComponent(fileName)
    }
    
    func openDirectory() {
        guard let documentDirectory = getDirectory(),
                  let components = NSURLComponents(url: documentDirectory, resolvingAgainstBaseURL: true) else {
                return
            }
            components.scheme = "shareddocuments"
            
            if let sharedDocuments = components.url {
                UIApplication.shared.open(
                    sharedDocuments,
                    options: [:],
                    completionHandler: nil
                )
            }
    }
    
    func saveSCNFileToDisk() {
        let sceneToSave = SCNScene()
        
        arView.scene.anchors.forEach { element in
            let node = SCNNode();
            
            node.position = SCNVector3(element.position)
            node.transform = SCNMatrix4(element.transform.matrix)
            node.name = "Anchor\(sceneToSave.rootNode.childNodes.count)"
            
            node.geometry = SCNSphere(radius: 8)
            
            sceneToSave.rootNode.addChildNode(node)
        }
        
        if let path = getPathToSave("\(self.filename).usda") {
            
            print("Saving to documents: \(path)")
            
            let cameraNode = SCNNode()
            
            cameraNode.camera = SCNCamera()
            cameraNode.camera!.name = "iPhoneCamera"
            cameraNode.name = "CameraNode"
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
            
            sceneToSave.rootNode.addChildNode(cameraNode)
            
            let animation = [
                "CameraNode": [
                    "transform": cameraTransforms
                ]
            ]
            
            sceneToSave.writeToUsda(url: path, animation: animation, fps: self.fps)

            openDirectory()
        }
    }
    
    func addAnchor() {
        if let anchor = try? ARScene.loadBox() {
//            if let anchor = try? Entity.loadAnchor(named: "axis") {
            arView.scene.anchors.append(anchor)
        }
    }
    
    func updateCameraTransform() {
        cameraTransforms.append(arView.cameraTransform.matrix)
    }
}

extension ARManager : ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if (isRecording) {
            self.updateCameraTransform()
            // recording video
            videoWriter?.submit(pixelBuffer: frame.capturedImage)
            
            if recordLidar {
                // recording LiDAR video
                if let depthMap = frame.sceneDepth?.depthMap {
                    let dataImage = CIImage(cvPixelBuffer: depthMap)
                    var pixelBuffer: CVPixelBuffer?
                    
                    if self.pixelBufferCreateFromImage(ciImage: dataImage, outBuffer: &pixelBuffer) == kCVReturnSuccess {
                        
                        if pixelBuffer != nil {
                            lidarWriter?.submit(pixelBuffer: pixelBuffer!)
                        } else {
                            print("Empty pixel buffer")
                        }
                    } else {
                        print("Failed to convert depth data")
                    }
                } else {
                    print("Nothing to record from LiDAR")
                }
            }
        }
    }
    
    // Converting pixel format from lidar to bgra
    func pixelBufferCreateFromImage(ciImage: CIImage, outBuffer: UnsafeMutablePointer<CVPixelBuffer?>) -> CVReturn {
        let context = CIContext()
        let attributes = [
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferCGImageCompatibilityKey: true
        ] as CFDictionary
        
        let err = CVPixelBufferCreate(kCFAllocatorDefault, Int(ciImage.extent.width), Int(ciImage.extent.height), kCVPixelFormatType_32BGRA, attributes, outBuffer)
        
        if err != kCVReturnSuccess {
            print("Error: \(err)")
            return err
        }
        
        if let buffer = outBuffer.pointee {
            context.render(ciImage, to: buffer)
        } else {
            print("Buffer is empty")
        }
        
        return kCVReturnSuccess
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
// !!! --- Code alive, dont remove --- !!!
//        anchors.forEach { anchor in
//            if let arPlaneAnchor = anchor as? ARPlaneAnchor {
//                let id = arPlaneAnchor.identifier
//                if planes.contains(where: {$0.key == id}) {
//                    print("anchor already exists")
//                } else {
//                    let planeAnchorEntity = PlaneAnchorEntity(arPlaneAnchor: arPlaneAnchor)
//                    arView.scene.anchors.append(planeAnchorEntity)
//                    planes[id] = planeAnchorEntity
//                }
//            }
//        }
    }

}
