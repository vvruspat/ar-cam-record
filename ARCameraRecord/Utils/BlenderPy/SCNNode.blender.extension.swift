//
//  SCNNode.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import SceneKit

extension SCNNode {
    func toBlenderPyNode(_ animation: KeyframeAnimation, _ isRoot: Bool = false) -> String {
        var blenderPyNode = ""
        let varName = isRoot ? "rootAnchor" : "anchor"

        if (self.camera != nil) {
            blenderPyNode += self.camera!.toBlenderPyCamera(animation, self.name?.replacingOccurrences(of: " ", with: "") ?? "Camera\(Int.random(in: 0...100))") + "\n"
        } else {
            
            if (isRoot) {
                blenderPyNode += "rotation_degrees = (90.0, 0.0, 0.0)\n"
                blenderPyNode += "rotation_radians = [math.radians(deg) for deg in rotation_degrees]\n"
                blenderPyNode += "bpy.ops.object.empty_add(location=\(SIMD3(self.position.x, self.position.y, self.position.z).toBlenderPy()), rotation=rotation_radians)\n"
            } else {
                blenderPyNode += "bpy.ops.object.empty_add(location=\(SIMD3(self.position.x, self.position.y, self.position.z).toBlenderPy()))\n"
            }
            
            blenderPyNode += "\(varName) = bpy.context.object\n"
            blenderPyNode += "\(varName).empty_display_type = 'ARROWS'\n"
            blenderPyNode += "\(varName).name = \"\(self.name?.replacingOccurrences(of: " ", with: "") ?? "Anchor\(Int.random(in: 0...100))")\"\n"
            
            if (!isRoot) {
                blenderPyNode += "\(varName).parent = rootAnchor"
//                blenderPyNode += "\(varName).matrix_parent_inverse = rootAnchor.matrix_world.inverted()"
            }
        }
        
        self.childNodes.forEach { node in
            blenderPyNode += node.toBlenderPyNode(animation) + "\n"
        }
        
        return blenderPyNode
    }
}
