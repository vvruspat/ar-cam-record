//
//  SCNScene.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import SceneKit

extension SCNScene {
    func exportToBlenderPy(animation: KeyframeAnimation, fps: Float) -> String {
        var blenderPyData = "import bpy\n"

        blenderPyData += "bpy.context.scene.frame_end = \(animation["CameraNode"]?.keyTimes.count ?? 1)\n"
        blenderPyData += "bpy.context.scene.render.fps = \(Int(fps))\n"

        blenderPyData += self.rootNode.toBlenderPyNode(animation)
        
        return blenderPyData
    }
    
    func writeToBlenderPy(url: URL, animation: KeyframeAnimation, fps: Float) {
        let data = self.exportToBlenderPy(animation: animation, fps: fps)
        
        do {
            try data.write(to: url, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("failed to write file \(url)")
            print(error.localizedDescription)
        }
    }
}
