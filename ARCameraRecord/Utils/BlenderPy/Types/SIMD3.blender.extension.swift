//
//  SIMD3.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import Foundation

extension SIMD3: BlenderPyConvertable {
    func toBlenderPy() -> String {
        return "(\(self.x),\(self.y),\(self.z))"
    }
}
