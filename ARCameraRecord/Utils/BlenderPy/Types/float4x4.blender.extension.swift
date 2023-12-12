//
//  float4x4.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import simd

extension float4x4: BlenderPyConvertable {
    func toBlenderPy() -> String {
        var result = "("
        
        for index in 0..<4 {
            if (index > 0) {
                result += ", "
            }
            result += "(\(self[index].x), \(self[index].y), \(self[index].z), \(self[index].w))"
        }
        
        result += ")"
        
        return result
    }
}
