//
//  SCNNode.extension.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import SceneKit

extension SCNNode {
    func toUsdaNode(_ animation: KeyframeAnimation) -> String {
        var usdaNode = "def Xform \"\(self.name?.replacingOccurrences(of: " ", with: "") ?? "Node\(Int.random(in: 0...100))")\" {\n"
        let nodeAnimation = animation[self.name ?? ""] ?? [:]
        var isTranformAnimated = false
        
        nodeAnimation.forEach { key, value in
            if (key == "transform") {
                isTranformAnimated = true
            }
                
            usdaNode += "\t " + UsdaUtils.getAnimatedAttribute(attrName: key, attrValue: value) + "\n"
        }
        
        if (!isTranformAnimated) {
            usdaNode += "\t " + UsdaUtils.getAttribute(attrName: "transform", attrValue: float4x4(self.transform)) + "\n"
        }
        
        if (self.camera != nil) {
            usdaNode += "\t " + self.camera!.tUsdaCamera() + "\n"
        }
        
//        if (self.geometry !== nil) {
//            usdaNode += "\t " + self.geometry!.toUsdaGeometry() + "\n"
//        }
        
        self.childNodes.forEach { node in
            usdaNode += "\t " + node.toUsdaNode(animation) + "\n"
        }
        
        usdaNode += "}\n"
        
        return usdaNode
    }
}
