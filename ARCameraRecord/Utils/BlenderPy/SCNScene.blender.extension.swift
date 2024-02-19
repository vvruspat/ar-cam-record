//
//  SCNScene.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import SceneKit

extension SCNScene {
    func exportToBlenderPy(animation: KeyframeAnimation, fps: Float, isVertical: Bool, videoFileName: String) -> String {
        var blenderPyData = "import bpy\n"
        
        blenderPyData += "import math\n"

        blenderPyData += "bpy.context.scene.frame_end = \(animation["CameraNode"]?.keyTimes.count ?? 1)\n"
        blenderPyData += "bpy.context.scene.render.fps = \(Int(fps))\n"

        if (isVertical) {
            blenderPyData += "bpy.context.scene.render.resolution_y = 3840\n"
            blenderPyData += "bpy.context.scene.render.resolution_x = 2160\n"
        } else {
            blenderPyData += "bpy.context.scene.render.resolution_y = 2160\n"
            blenderPyData += "bpy.context.scene.render.resolution_x = 3840\n"
        }

        blenderPyData += self.rootNode.toBlenderPyNode(animation, true, isVertical: isVertical)
        
        return blenderPyData
    }
    
    func writeToBlenderPy(url: URL, animation: KeyframeAnimation, fps: Float, isVertical: Bool, videoFileName: String) {
        let data = self.exportToBlenderPy(animation: animation, fps: fps, isVertical: isVertical, videoFileName: videoFileName)
        
        do {
            try data.write(to: url, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("failed to write file \(url)")
            print(error.localizedDescription)
        }
    }
}
