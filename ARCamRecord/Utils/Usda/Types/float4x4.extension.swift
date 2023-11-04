//
//  float4x4.extension.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import simd

extension float4x4: USDAConvertable {
    func toUsda() -> String {
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
    
    func getUsdaType() -> String {
        return "matrix4d"
    }
}
