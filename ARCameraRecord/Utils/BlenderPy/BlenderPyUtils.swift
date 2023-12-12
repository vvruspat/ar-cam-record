//
//  Utils.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import Foundation
import simd

func eulerAngleFrom(_ rotationMatrix: simd_float3x3) -> SIMD3<Float> {
    let yaw = atan2(rotationMatrix[0][2], rotationMatrix[2][2])
    let pitch = atan2(-rotationMatrix[1][2], sqrt(pow(rotationMatrix[0][2], 2) + pow(rotationMatrix[2][2], 2)))
    let roll = atan2(rotationMatrix[1][0], rotationMatrix[1][1])

    return SIMD3<Float>(roll, pitch, yaw)
}
