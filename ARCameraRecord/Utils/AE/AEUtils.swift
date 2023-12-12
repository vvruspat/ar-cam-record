//
//  AEUtils.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 21/11/2023.
//

import Foundation
import SceneKit

func rotationMatrixToEulerAngles(_ transformMatrix: matrix_float4x4) -> SIMD3<Float> {
    // Extract individual elements from the rotation matrix
    let m00 = transformMatrix.columns.0.x;
    let m02 = transformMatrix.columns.0.z;
    let m10 = transformMatrix.columns.1.x;
    let m20 = transformMatrix.columns.2.x;
    let m21 = transformMatrix.columns.2.y;
    let m22 = transformMatrix.columns.2.z;

    // Calculate Euler angles (in radians)
    var x: Float = 0.0;
    var y: Float = 0.0;
    var z: Float = 0.0;
    
    if (m10 > 0.998) { // Singularity at north pole
        y = Float(atan2(m02, m22));
        x = Float.pi / 2;
        z = 0.0;
    } else if (m10 < -0.998) { // Singularity at south pole
        y = Float(atan2(m02, m22));
        x = Float(-1 * Float.pi / 2);
        z = 0.0;
    } else {
        y = Float(atan2(-m20, sqrt(m00 * m00 + m10 * m10)));
        x = Float(atan2(m10, m00));
        z = Float(atan2(m21, m22));
    }

    // Convert Euler angles to degrees
    x *= (180 / Float.pi);
    y *= (180 / Float.pi);
    z *= (180 / Float.pi);

    return SIMD3<Float>(x: x, y: y, z: z); // Return Euler angles as an object
}
