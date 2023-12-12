//
//  SCNNode.ae.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 19/11/2023.
//

import Foundation
import SceneKit

extension SCNNode {
    func toAENode(_ animation: KeyframeAnimation) -> String {
        var aeNode = ""

        if (self.camera != nil) {
            aeNode += self.camera!.toAECamera(animation, self.name?.replacingOccurrences(of: " ", with: "") ?? "Camera\(Int.random(in: 0...100))") + "\n"
        } else {
            let name = self.name?.replacingOccurrences(of: " ", with: "") ?? "Anchor\(Int.random(in: 0...100))"
            
            aeNode += "var anchor = comp.layers.addNull();\n"
            aeNode += "anchor.name = \"\(name)\";\n"
            aeNode += "anchor.threeDLayer = true;\n"
            aeNode += "anchor.position.setValue(\((SIMD3<Float>(self.position.x, self.position.y, self.position.z) * Float(AE_MULTIPLIER)).toAE()));\n"
        }
        
        self.childNodes.forEach { node in
            aeNode += node.toAENode(animation) + "\n"
        }
        
        return aeNode
    }
}
