//
//  SCNCamera.ae.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 19/11/2023.
//

import Foundation
import SceneKit

extension SCNCamera {
    func toAECamera(_ animation: KeyframeAnimation, _ name: String) -> String {
        var result = "\n"
        
        result += "var cameraLayer = comp.layers.addCamera(\"\(name)\", [comp.width / 2, comp.height / 2]);\n"
        result += "var camera = cameraLayer.property(\"ADBE Transform Group\");\n"
        result += "var camPosition = camera.property(\"Position\");\n"
        result += "var camXRotation = camera.property(\"X Rotation\");\n"
        result += "var camYRotation = camera.property(\"Y Rotation\");\n"
        result += "var camZRotation = camera.property(\"Z Rotation\");\n"
        
        if let nodeAnimation = animation[name] {
            var index = 0
            var rotations = ""
            var locations = ""
            var keyframes = ""
            
            nodeAnimation.keyTimes.forEach { time in
                let transformMatrix = nodeAnimation.localTransform(atTime: TimeInterval.init(truncating: time))
                
                let position = SIMD3<Float>(transformMatrix.columns.3.x, transformMatrix.columns.3.y, transformMatrix.columns.3.z)

//                let rotation = nodeAnimation.rotation(atTime: TimeInterval.init(truncating: time))
                let rotation = rotationMatrixToEulerAngles(transformMatrix)
                
                if (index > 0) {
                    if (index > 1) {
                        keyframes += ","
                        locations += ","
                        rotations += ","
                    }
                    
                    keyframes += "\(index)"
                    locations += "\(position.toAE())"
                    rotations += "\(rotation.toAE())"
                }
                
                index += 1
            }
            
            result += "var locations = [\(locations)];\n"
            result += "var rotations = [\(rotations)];\n"
        }
        
        result += "for (var i = 0; i < locations.length; i++) {\n"
        result += "\tcamPosition.setValueAtTime(i, [locations[i][0] * MULTIPLIER, locations[i][1] * MULTIPLIER, locations[i][2] * MULTIPLIER, ]);\n"
        result += "\tcamXRotation.setValueAtTime(i, rotations[i][0]);\n"
        result += "\tcamYRotation.setValueAtTime(i, rotations[i][1]);\n"
        result += "\tcamZRotation.setValueAtTime(i, rotations[i][2]);\n"
        result += "}"

        return result
    }

}
