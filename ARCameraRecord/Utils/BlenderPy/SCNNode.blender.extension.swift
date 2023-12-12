//
//  SCNNode.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import SceneKit

extension SCNNode {
    func toBlenderPyNode(_ animation: KeyframeAnimation) -> String {
        var blenderPyNode = ""

        if (self.camera != nil) {
            blenderPyNode += self.camera!.toBlenderPyCamera(animation, self.name?.replacingOccurrences(of: " ", with: "") ?? "Camera\(Int.random(in: 0...100))") + "\n"
        } else {
            blenderPyNode += "bpy.ops.object.empty_add(location=\(SIMD3(self.position.x, self.position.y, self.position.z).toBlenderPy()))\n"
            blenderPyNode += "anchor = bpy.context.object\n"
            blenderPyNode += "anchor.name = \"\(self.name?.replacingOccurrences(of: " ", with: "") ?? "Anchor\(Int.random(in: 0...100))")\"\n"
        }
        
        self.childNodes.forEach { node in
            blenderPyNode += node.toBlenderPyNode(animation) + "\n"
        }
        
        return blenderPyNode
    }
}
