//
//  ARManager.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 24/09/2023.
//

import RealityKit
import SceneKit
import ARKit

class ARManager: NSObject, ObservableObject {
    static let shared = ARManager()
    
    let arView: ARView
    let scene = SCNScene(named: "empty.usdz")
    let sceneToSave = SCNScene()
    var cameraTransforms: Array<float4x4> = []
    
    var timer: Timer?
    var counter = 0
    var timeStart: TimeInterval?
    
    var fps: Float = 30.0
    var videoWriter: VideoWriter?
    
    var filename = "ar-captured"
    
    @Published var isRecording = false
    
    override init() {
        
        arView = ARView(frame: .zero)
        
        super.init()
        
        let config = ARWorldTrackingConfiguration()
            
        if let hiResFormat = ARWorldTrackingConfiguration.recommendedVideoFormatFor4KResolution {
            config.videoFormat = hiResFormat
            print("Hires available")
        }
        
        config.planeDetection = [.horizontal, .vertical]
                
        arView.session.run(config)
        
        fps = Float(config.videoFormat.framesPerSecond)

        arView.session.delegate = self
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
        cameraNode.camera!.name = "iPhoneCamera"
        cameraNode.name = "CameraNode"
        
        sceneToSave.rootNode.addChildNode(cameraNode)

        if scene != nil {
            scene!.rootNode.addChildNode(cameraNode)
        } else {
            print("Scene is nil")
        }
        
    }
    
    func record () async {
        let session = await self.arView.session
        self.filename = "ar-captured-\(round(Date.now.timeIntervalSince1970))"
        
        videoWriter = VideoWriter()
        videoWriter?.frameTime = Double(1.0 / self.fps)
        videoWriter?.width = Int(session.configuration?.videoFormat.imageResolution.width ?? 3840.0)
        videoWriter?.height = Int(session.configuration?.videoFormat.imageResolution.height ?? 2160.0)
        videoWriter?.url = self.getPathToSave("\(self.filename).mov")
        videoWriter?.start()
        
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        self.isRecording = false
        videoWriter?.complete();
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
        arView.scene.anchors.forEach { element in
            let node = SCNNode();
            
            node.position = SCNVector3(element.position)
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
            cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
            
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
        do {
            let anchor = try ARScene.loadBox()
            
            arView.scene.anchors.append(anchor)
            print("anchor added \(anchor.position)")
        } catch {
            print("Failed to load Box \(error.localizedDescription)")
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
            videoWriter?.submit(pixelBuffer: frame.capturedImage)
        }
    }
}
