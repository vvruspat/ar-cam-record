//
//  SCNScene.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import SceneKit

extension SCNScene {
    func exportToBlenderPy(animation: KeyframeAnimation, fps: Float, videoFileName: String) -> String {
        var blenderPyData = "import bpy\n"

        blenderPyData += "bpy.context.scene.frame_end = \(animation["CameraNode"]?.keyTimes.count ?? 1)\n"
        blenderPyData += "bpy.context.scene.render.fps = \(Int(fps))\n"

        blenderPyData += "image_path = \"\(videoFileName)\"\n"
        blenderPyData += "if image_path in bpy.data.images:\n"
        blenderPyData += "    background_image = bpy.data.images[image_path]\n"
        blenderPyData += "else:\n"
        blenderPyData += "    background_image = bpy.data.images.load(image_path)\n"

        
        blenderPyData += self.rootNode.toBlenderPyNode(animation)
        
        return blenderPyData
    }
    
    func writeToBlenderPy(url: URL, animation: KeyframeAnimation, fps: Float, videoFileName: String) {
        let data = self.exportToBlenderPy(animation: animation, fps: fps, videoFileName: videoFileName)
        
        do {
            try data.write(to: url, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("failed to write file \(url)")
            print(error.localizedDescription)
        }
    }
}
