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
        var isTranformAnimated = false
        
        if let nodeAnimation = animation[self.name ?? ""] {
            isTranformAnimated = true
            usdaNode += "\t " + UsdaUtils.getAnimatedAttribute(attrName: "transform", attrValue: nodeAnimation.keyTimes.map({ time in
                return nodeAnimation.localTransform(atTime: TimeInterval.init(truncating: time))
            })) + "\n"
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
