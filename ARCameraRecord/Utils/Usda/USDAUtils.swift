//
//  USDAUtils.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import Foundation
import simd

struct UsdaUtils {
    static func getAttributePythonType(attr: USDAConvertable?) -> String {
        return attr?.getUsdaType() ?? "token"
    }
    
    static func getPythonPresentation(attr: USDAConvertable?) -> String {
        return attr?.toUsda() ?? ""
    }
    
    static func getAnimatedAttribute(attrName: String, attrValue: Array<USDAConvertable>) -> String {
        let pythonType = UsdaUtils.getAttributePythonType(attr: attrValue.first)
        
        var result = "\n\t \(pythonType) xformOp:\(attrName).timeSamples = \(attrValue.toUsda())"
            result += "\n\t uniform token[] xformOpOrder = [\"xformOp:\(attrName)\"]"
        
        return result
    }
    
    static func getAttribute(attrName: String, attrValue: float4x4) -> String {
        let pythonType = UsdaUtils.getAttributePythonType(attr: attrValue)
        
        // TODO: Now thats only works for transform, but need to fix for all types of attributes
        var result = "\n\t \(pythonType) xformOp:\(attrName) = \(attrValue.toUsda())"
            result += "\n\t uniform token[] xformOpOrder = [\"xformOp:\(attrName)\"]"
        
        return result
    }
}
