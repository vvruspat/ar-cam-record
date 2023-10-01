//
//  usda_export.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 26/09/2023.
//

import SceneKit

typealias KeyframeAnimation = [String:[String:Array<Any>]]

extension SCNScene {
    func exportToUsda(animation: KeyframeAnimation, fps: Float) -> String {
        var usdaData = "#usda 1.0\n"
        
        usdaData += "(\n"
        usdaData += "\t defaultPrim = \"Light\"\n"
        usdaData += "\t doc = \"ArCamRecord\"\n"
        usdaData += "\t endTimeCode = \(animation["CameraNode"]?["transform"]?.count ?? 1)\n"
        usdaData += "\t metersPerUnit = 1\n"
        usdaData += "\t startTimeCode = 1\n"
        usdaData += "\t timeCodesPerSecond = \(fps)\n"
        usdaData += "\t upAxis = \"Z\"\n"
        usdaData += ")\n"

        
        usdaData += "\t" + self.rootNode.toUsdaNode(animation)
        
        return usdaData
    }
    
    func writeToUsda(url: URL, animation: KeyframeAnimation, fps: Float) {
        let data = self.exportToUsda(animation: animation, fps: fps)
        
        do {
            try data.write(to: url, atomically: false, encoding: String.Encoding.ascii)
        } catch {
            print("failed to write file \(url)")
            print(error.localizedDescription)
        }
    }
}

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

extension SCNCamera {
    func tUsdaCamera() -> String {
        var result = "def Camera \"\(self.name?.replacingOccurrences(of: " ", with: "") ?? "")\" \n { \n"
        
        result += "\t float focalLength = \(self.focalLength) \n"
        result += "\t float horizontalAperture = \(self.sensorHeight / self.fStop * (9.0 / 16.0)) \n"
        result += "\t float horizontalApertureOffset = 0 \n"
        result += "\t float2 clippingRange = (1, 100) \n"
        result += "\t token projection = \"perspective\" \n"
        result += "\t float verticalAperture = \(self.sensorHeight / self.fStop) \n"
        result += "\t float verticalApertureOffset = 0 \n"
        result += "}\n"
        
        return result
    }
}

//extension SCNGeometry {
//    func toUsdaGeometry() -> String {
//        var result = "def Mesh \"Cube\" \n { \n"
//
//        result += "\t uniform bool doubleSided = 1 \n"
//        result += "\t float3[] extent = [(-1, -1, -1), (1, 1, 1)] \n"
//        result += "\t int[] faceVertexCounts = [4, 4, 4, 4, 4, 4] \n"
//        result += "\t int[] faceVertexIndices = [0, 4, 6, 2, 3, 2, 6, 7, 7, 6, 4, 5, 5, 1, 3, 7, 1, 0, 2, 3, 5, 4, 0, 1] \n"
//        result += "\t normal3f[] normals = [(0, 0, 1), (0, 0, 1), (0, 0, 1), (0, 0, 1), (0, -1, 0), (0, -1, 0), (0, -1, 0), (0, -1, 0), (-1, 0, 0), (-1, 0, 0), (-1, 0, 0), (-1, 0, 0), (0, 0, -1), (0, 0, -1), (0, 0, -1), (0, 0, -1), (1, 0, 0), (1, 0, 0), (1, 0, 0), (1, 0, 0), (0, 1, 0), (0, 1, 0), (0, 1, 0), (0, 1, 0)] (interpolation = \"faceVarying\") \n"
//        result += "}\n"
//        
//        return result
//    }
//}

struct UsdaUtils {
    static func getAttributePythonType(attr: Any?) -> String {
        switch attr {
            
        case is Bool : return "bool"
        case is Int : return "int"
        case is float4x4 : return "matrix4d"
        case is SIMD2<Float> : return "float2"
        case is SIMD3<Float> : return "float3"
        case is Float : return "float"
        case is String : return "token"
        default: return "token"
            
        }
    }
    
    static func getPythonPresentation(attr: Any?) -> String {
        if (attr != nil) {
            switch attr {
                
            case is float4x4 : return (attr as! float4x4).toUsda()
            case is SIMD2<Float> : return (attr as! SIMD2<Float>).toUsda()
            case is SIMD3<Float> : return (attr as! SIMD3<Float>).toUsda()
                
            default: return "\(attr!)"
                
            }
        } else {
            return ""
        }
    }
    
    static func getAnimatedAttribute(attrName: String, attrValue: Array<Any>) -> String {
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

extension float4x4 {
    func toUsda() -> String {
        var result = "("
        
        for index in 0..<4 {
            if (index > 0) {
                result += ", "
            }
            result += "(\(self[index][0]), \(self[index][1]), \(self[index][2]), \(self[index][3]))"
        }
        
        result += ")"
        
        return result
    }
}

extension Array {
    func toUsda() -> String {
        var index = 0
        var result = "{\n"
        
        self.forEach { element in
            if (index > 0) {
                if (index > 1) {
                    result += ",\n"
                }
                
                result += "\(index) : \(UsdaUtils.getPythonPresentation(attr: element))"
            }
            index += 1
        }
        
        result += "}\n"
        
        return result
    }
}

extension SIMD2 {
    func toUsda() -> String {
        return ""
    }
}

extension SIMD3 {
    func toUsda() -> String {
        return ""
    }
}

