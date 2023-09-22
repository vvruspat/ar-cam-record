//
//  ContentView.swift
//  ARCamRecord
//
//  Created by Елена Белова on 28/07/2023.
//

import SwiftUI
import RealityKit
import SceneKit
import MetalKit
import ModelIO

struct ContentView: View {
    @State var isRecording = false
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveSCNFileToDisk() {
        let url = getDocumentsDirectory().appendingPathComponent("test.usdz")
        
        print("Saving to documents: ")
        
        print(url)

        ARViewContainer.newScene!.write(to: url, options: nil, delegate: nil) { float, error, pointer in
            if let error = error {
                print("failed")
                print(error.localizedDescription)
                return
            } else {
                print("saved successfully")
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            HStack(alignment: .bottom) {
                Button("Add") {
                    let anchor = try! ARScene.loadBox()

                    ARViewContainer.arView.scene.anchors.append(anchor)
                }
                Spacer()
                Button(isRecording ? "Stop" : "Record") {
                    isRecording = !isRecording
//                        guard let device = MTLCreateSystemDefaultDevice()
//                            else { fatalError("Can't create MTLDevice") }
//                        let allocator = MTKMeshBufferAllocator(device: device)
//                        let asset = MDLAsset(bufferAllocator: allocator)
//
//                        let filePath = FileManager.default.urls(for: .documentDirectory,
//                                                                     in: .userDomainMask).first!
//
//                        let usd: URL = filePath.appendingPathComponent("model.usd")
//
//                        if MDLAsset.canExportFileExtension("usd") {
//                            do {
//                                try asset.export(to: usd)
//
////                                    let controller = UIActivityViewController(activityItems: [usd],
////                                                                      applicationActivities: nil)
////                                    controller.popoverPresentationController?.sourceView = sender
////                                    self.present(controller, animated: true, completion: nil)
//
//                            } catch let error {
//                                fatalError(error.localizedDescription)
//                            }
//                        } else {
//                            fatalError("Can't export USD")
//                        }
////                    } else {
//////                        ARViewContainer.arView.session.run(ARConfiguration())
////                    }
                    ///
                    if (!isRecording) {
                        saveSCNFileToDisk()
                    }
                }
            }.padding(20)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    static let arView = ARView(frame: .zero)
    static let newScene = SCNScene(named: "empty.usdz")

    static var animation = CAKeyframeAnimation(keyPath: "transform")
    
    init() {
        // 2: Add camera node
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
        // 4: Set camera on scene
        
        if ((ARViewContainer.newScene) != nil) {
            ARViewContainer.newScene!.rootNode.addChildNode(cameraNode)
            ARViewContainer.newScene!.rootNode.camera?.addAnimation(ARViewContainer.animation, forKey: "transform")
        } else {
            print("Scene is nil")
        }
    }
    
    func makeUIView(context: Context) -> some UIView {
        let anchor = try! ARScene.loadBox()

        ARViewContainer.arView.scene.anchors.append(anchor)

        return ARViewContainer.arView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        print(ARViewContainer.arView.cameraTransform)
        
        updateCameraTransform()
//
//        ARViewContainer.arView.scene.anchors.forEach { element in
//            print(element.position)
//        }
    }
    
    func updateCameraTransform() {
        var cameraTransforms: Array<Transform> = ARViewContainer.animation.values as? Array<Transform> ?? []
        
        cameraTransforms.append(ARViewContainer.arView.cameraTransform)
        
        ARViewContainer.animation.values = cameraTransforms
        
        let fps: Double = 60.0
        let timePerFrame: Double = 1.0 / fps
        
        // Set the animation's duration and repeat count
        ARViewContainer.animation.duration = CFTimeInterval(cameraTransforms.count) * timePerFrame
        ARViewContainer.animation.repeatCount = .infinity
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
