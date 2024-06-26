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

    static let shared = ARManager()
    
    var planes = [UUID: PlaneAnchorEntity]()
    
    var onboardingManager = OnboardingManager.shared
    
    var arView: ARView
    var cameraTransforms = MDLTransform()
    var startTransform: matrix_float4x4?
    var startRotation: simd_float3?
    var startTime: TimeInterval?
    var anchors: [simd_float4x4] = []
    var timer: Timer?
    var counter = 0

    var fps: Float = 30.0
    var imageWidth: Int = 3840
    var imageHeight: Int = 2160
    var startAnimation = 1
    var videoWriter: VideoWriter?

    var filename = "ar-captured"

    var sceneToSave = SCNScene()
    var cameraNode = SCNNode()
    let config = ARWorldTrackingConfiguration()
    var planeDetection = false
    
    var highlightedPlane: UUID?
    var selectedFloorPlane: UUID?

    let supportLidar = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    
    @Published var isRecording = false
    @Published var isFloorDetected = false
    @Published var distance = 0.0
    @Published var recordingStartTime = 0.0
    @Published var recordingTime = 0.0
    
    @Published var orientation = InterfaceOrientation.landscapeRight
    
    @AppStorage(SettingsKeys.showLidar) var showLidar = false
    
    override init() {
        arView = ARView(frame: .zero)
        
        super.init()
        
        UserDefaults.standard.addObserver(self, forKeyPath: SettingsKeys.showLidar, options: .new, context: nil)
        setOrientation(InterfaceOrientation.landscapeRight)
        setup()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: SettingsKeys.showLidar)
    }
    
    func setOrientation(_ orient: InterfaceOrientation) {
        orientation = orient
        AppDelegate.orientationLock = orient == InterfaceOrientation.portrait ? UIInterfaceOrientationMask.portrait : UIInterfaceOrientationMask.landscapeRight
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    func setup() {
        arView.session.pause()
                        
        arView.automaticallyConfigureSession = false
        
        sceneToSave.rootNode.position = SCNVector3(0, 0, 0)
        sceneToSave.rootNode.rotation = SCNVector4(0, 0, 0, 0)
        sceneToSave.rootNode.name = "ARCamRecord"
        
        cameraNode.position = SCNVector3(0, 0, 0)
        cameraNode.rotation = SCNVector4(0, 0, 0, 0)
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.name = "iPhoneCamera"
        cameraNode.name = "CameraNode"

        sceneToSave.rootNode.addChildNode(cameraNode)

        config.worldAlignment = .gravity
        config.providesAudioData = true
           
        if let hiResFormat = ARWorldTrackingConfiguration.recommendedVideoFormatFor4KResolution {
            config.videoFormat = hiResFormat
        }
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics = .sceneDepth
        }

        planeDetection = true
        
        config.planeDetection = [.horizontal, .vertical]
        arView.contentScaleFactor = 1

        if (showLidar) {
            config.sceneReconstruction = .meshWithClassification
            arView.debugOptions.insert(.showSceneUnderstanding)
        }

        imageWidth = Int(arView.session.configuration?.videoFormat.imageResolution.width ?? 3840.0)
        imageHeight = Int(arView.session.configuration?.videoFormat.imageResolution.height ?? 2160.0)
        
        setupVideoWriter()
        
        arView.session.delegate = self
        
        arView.session.run(config, options: [.resetTracking, .resetSceneReconstruction, .removeExistingAnchors])
        
        if let anchorEntity = try? Entity.loadAnchor(named: "axis") {

            let position: SIMD3<Float> = SIMD3(x: 0.0, y: 0.0, z: 0.0)
            
            anchorEntity.setPosition(position, relativeTo: nil)
        }
        
        fps = Float(config.videoFormat.framesPerSecond)
        
        onboardingManager.goToStep(step: .move)
    }
    
    func setupVideoWriter() {
        
        self.filename = "ar-captured-\(Int(Date.now.timeIntervalSince1970))"
        
        videoWriter = VideoWriter()
        videoWriter?.frameTime = Double(1.0 / self.fps)
        
        videoWriter?.width = imageWidth
        videoWriter?.height = imageHeight
        videoWriter?.url = self.getTmpPathToSave("\(self.filename).mov")
        
        DispatchQueue.global(qos: .background).async {
            self.videoWriter?.start(self.orientation == InterfaceOrientation.landscapeRight ? false : true)
        }
    }
    
    func reset() {
        arView.scene.anchors.removeAll()
        planes.removeAll()
        anchors.removeAll()
        cameraTransforms = MDLTransform()
        counter = 0
        startTime = nil
        startTransform = nil
        startRotation = nil
        recordingTime = 0.0
        recordingStartTime = 0.0

        startAnimation = 1

        sceneToSave = SCNScene()
        cameraNode = SCNNode()
        planeDetection = false
        
        highlightedPlane = nil
        selectedFloorPlane = nil
        
        videoWriter = nil
        
        isFloorDetected = false
        distance = 0.0
        
        setup()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if showLidar {
           self.arView.debugOptions.insert(.showSceneUnderstanding)
        } else {
           self.arView.debugOptions.remove(.showSceneUnderstanding)
        }
    }
    
    func startRecording () {
        addStartFrameToCameraTransform()
        startAnimation = self.cameraTransforms.keyTimes.count
        recordingTime = 0.0
        recordingStartTime = arView.session.currentFrame?.timestamp ?? 0.0

        isRecording = true
        

        videoWriter?.startAudioRecording()

        onboardingManager.goToStep(step: .recording)
    }
    
    func stopRecording() {
        isRecording = false
        
        videoWriter?.complete()

        saveSCNFileToDisk()
        onboardingManager.goToStep(step: nil)
        
        reset()
    }
    
    func toggleRecord() {
        if (isRecording) {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func getDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first
    }
    
    func getPathToSave(_ fileName: String, folder: URL?) -> URL? {
        return folder?.appendingPathComponent(fileName)
    }
    
    func getTmpPathToSave(_ fileName: String) -> URL? {
        let tempFilePath = NSTemporaryDirectory() + fileName
        let tempURL = URL(fileURLWithPath: tempFilePath)
        
        return tempURL
    }
    
    func openDirectory(_ folder: URL?) {
        guard let documentDirectory = folder ?? getDirectory(),
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
    
    func moveFile(from: URL, to: URL) {
        do {
            if FileManager.default.fileExists(atPath: to.path) {
                try FileManager.default.removeItem(atPath: to.path)
            }
            try FileManager.default.moveItem(atPath: from.path, toPath: to.path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveSCNFileToDisk() {
        var index = 1
        
        anchors.forEach { element in
            let node = SCNNode();
            
            node.transform = SCNMatrix4(element)
            node.name = "Anchor\(index)"
            
            sceneToSave.rootNode.addChildNode(node)
            
            index += 1
        }
        
        let animation: KeyframeAnimation = [
            "CameraNode": cameraTransforms
        ]
        
        if let path = getTmpPathToSave("\(self.filename).blender.py") {
            sceneToSave.writeToBlenderPy(url: path, animation: animation, fps: self.fps, isVertical: orientation != InterfaceOrientation.landscapeRight, videoFileName: "\(self.filename).mov")
        }

        finalizeSave()
    }
    
    func getDateFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss"
        
        return formatter
    }
    
    func getDateAsString() -> String {
        return getDateFormat().string(from: Date.now)
    }
    
    func createAppFolder() -> URL? {
        if let documentsDirectory = getDirectory() {
            let folderName = "Takes"
            let folderURL = documentsDirectory
                                .appendingPathComponent(folderName)
                                .appendingPathComponent("\(getDateAsString())")
            
            do {
                if !FileManager.default.fileExists(atPath: folderURL.path()) {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                } else {
                    print("Folder \(folderURL.path()) exist")
                }
                
                return folderURL
            } catch {
                print("Failed to create directory \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    func finalizeSave() {
        let folderToMove = createAppFolder()
        
        // Move python script
        if let tmpPath = getTmpPathToSave("\(self.filename).blender.py"),
           let path = getPathToSave("\(self.filename).blender.py", folder: folderToMove) {
            moveFile(from: tmpPath, to: path)
        }
        
        // Move Video
        if let path = getPathToSave("\(self.filename).mov", folder: folderToMove),
           let tmpPath = videoWriter?.url {
            moveFile(from: tmpPath, to: path)
        }

        openDirectory(folderToMove)
    }
    
    func addAnchor() {
        let testResult = arView.hitTest(arView.center, types: .existingPlane)
        
        if (testResult.isEmpty) {
            print("No plane detected")
        } else {
            if let anchorEntity = try? Entity.loadAnchor(named: "axis") {
                
                testResult.forEach { result in
                    if let id = result.anchor?.identifier {
                        if highlightedPlane == id {
                            let columns = result.worldTransform.columns.3
                            let position = SIMD3(x: columns.x, y: columns.y, z: columns.z)
                            
                            anchorEntity.setPosition(position, relativeTo: nil)
                            
                            let anchor = AnchorEntity(world: anchorEntity.position)
                            anchor.addChild(anchorEntity)
                            
                            // Add the anchor to the ARView's scene
                            arView.scene.addAnchor(anchor)
                            
                            anchors.append(testResult.first!.worldTransform)
                            
                            if planeDetection == true {
                                stopPlaneDetection()
                            }
                            
                            onboardingManager.goToStep(step: .record)
                        }
                    }
                }
            }
        }
    }
    
    func updateCameraTransform(_ frame: ARFrame, _ updateStart: Bool = false) {
        let transform = frame.camera.transform
        let rotation = frame.camera.eulerAngles
        let position = transform.columns.3
        let elapsedTime = frame.timestamp
        
        if (updateStart) {
            startTime = elapsedTime
            startTransform = transform
            startRotation = rotation
        } else {
            cameraTransforms.setTranslation(position[SIMD3(0,1,2)], forTime: elapsedTime)
            cameraTransforms.setRotation(rotation, forTime: elapsedTime)
        }
    }
    
    func addStartFrameToCameraTransform() {
        if (startTransform != nil && startTime != nil && startRotation != nil) {
            let transform = startTransform
            let rotation = startRotation!
            let position = transform!.columns.3
            let elapsedTime = startTime!
            
            cameraTransforms.setTranslation(position[SIMD3(0,1,2)], forTime: elapsedTime)
            cameraTransforms.setRotation(rotation, forTime: elapsedTime)
        }

    }
}

extension ARManager : ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if (isRecording) {
            updateCameraTransform(frame)
            // recording video
            videoWriter?.submit(pixelBuffer: frame.capturedImage)
            
            recordingTime = frame.timestamp;
        } else {
            updateCameraTransform(frame, true)
        }
        
        highlightFloorPlane()
        drawDistanceToCenter()
    }
    
    func drawDistanceToCenter() {
        let testResult = arView.hitTest(arView.center, types: .existingPlaneUsingGeometry)
        
        distance = Double(testResult.first?.distance ?? 0.0)
    }
    
    func highlightFloorPlane() {
        if !isFloorDetected {
            let testResult = arView.hitTest(arView.center, types: .existingPlaneUsingExtent)
            
            if let id = testResult.first?.anchor?.identifier {
                if let plane = planes[id] {
                    if highlightedPlane != nil {
                        planes[highlightedPlane!]?.deselect()
                    }
                    
                    highlightedPlane = id
                    plane.highlight()
                }
            }

        }
    }
    
    func selectFloorPlane() {
        guard highlightedPlane != nil else { return }
        
        planes.forEach { id, plane in
            plane.makeOpacity()
        }
        
        if let plane = planes[highlightedPlane!] {
            if selectedFloorPlane != nil {
                planes[selectedFloorPlane!]?.deselect()
            }
            
            selectedFloorPlane = highlightedPlane
            isFloorDetected = true
            stopPlaneDetection()
            plane.select()
            
            onboardingManager.goToStep(step: .anchor)
        }
    }
    
    func resetFloorSelection() {
        guard selectedFloorPlane != nil else { return }

        planes.forEach { id, plane in
            plane.deselect()
        }
        
        selectedFloorPlane = nil
        isFloorDetected = false
        startPlaneDetection()
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
        if planeDetection == false {
            return
        }
          
        anchors.forEach { anchor in
            if let arPlaneAnchor = anchor as? ARPlaneAnchor {
                
                onboardingManager.goToStep(step: .floor)
                
                let id = arPlaneAnchor.identifier
                
                if arPlaneAnchor.classification == .floor && isFloorDetected {
                    return
                }
                    
                if planes.contains(where: {$0.key == id}) {
                    print("anchor already exists")
                } else {
                    let planeAnchorEntity = PlaneAnchorEntity(arPlaneAnchor: arPlaneAnchor)
                    
                    arView.scene.anchors.append(planeAnchorEntity)
                    
                    planes[id] = planeAnchorEntity
                }
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if planeDetection == false {
            return
        }
        
        anchors.forEach { anchor in
            if let arPlaneAnchor = anchor as? ARPlaneAnchor {
                let id = arPlaneAnchor.identifier
                
                if planes.contains(where: {$0.key == id}) {
                    do {
                        try planes[id]?.didUpdate(arPlaneAnchor: arPlaneAnchor)
                    } catch {
                        print("Failed to update plane \(id)")
                    }
                }
            }
        }
    }
    
    func stopPlaneDetection() {
        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        // Update the configuration to stop plane detection
        config.planeDetection = []
        
        // Apply the updated configuration
        arView.session.run(config)
        
        planeDetection = false
    }
    
    func startPlaneDetection() {
        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        // Update the configuration to stop plane detection
        config.planeDetection = [.vertical, .horizontal]
        
        // Apply the updated configuration
        arView.session.run(config)
        
        planeDetection = true
    }
}
