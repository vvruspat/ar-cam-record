//
//  SCNScene.ae.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 19/11/2023.
//

import Foundation
import SceneKit

extension SCNScene {
    func exportToAE(animation: KeyframeAnimation, fps: Float) -> String {
        var aeData = "var comp = app.project.items.addComp(\"Camera Composition\", 1920, 1080, 1, \(animation["CameraNode"]?.keyTimes.count ?? 1), \(Int(fps)));\n"
        
        aeData += "var MULTIPLIER = \(AE_MULTIPLIER);"

        aeData += "\t" + self.rootNode.toAENode(animation)
        
        return aeData
    }
    
    func writeToAE(url: URL, animation: KeyframeAnimation, fps: Float) {
        let data = self.exportToAE(animation: animation, fps: fps)
        
        do {
            try data.write(to: url, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("failed to write file \(url)")
            print(error.localizedDescription)
        }
    }
}
