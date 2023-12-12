//
//  SIMD.ae.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 19/11/2023.
//

import Foundation
import simd

extension SIMD3: AEConvertable {
    func toAE() -> String {
        return "[\(self.x),\(self.y),\(self.z)]"
    }
}
