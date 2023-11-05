//
//  SIMD3.extension.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import Foundation

extension SIMD3: USDAConvertable {
    func toUsda() -> String {
        return ""
    }
    
    func getUsdaType() -> String {
        return "float3"
    }
}
