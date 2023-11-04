//
//  SCNCamera.extension.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import SceneKit

extension SCNCamera {
    func tUsdaCamera() -> String {
        var result = "def Camera \"\(self.name?.replacingOccurrences(of: " ", with: "") ?? "")\" \n { \n"

        result += "\t float focalLength = \(self.focalLength) \n"
        result += "\t float horizontalAperture = \(self.sensorHeight) \n"
        result += "\t float horizontalApertureOffset = 0 \n"
        result += "\t float verticalAperture = \(self.sensorHeight) \n"
        result += "\t float verticalApertureOffset = 0 \n"
        result += "\t float2 clippingRange = (0.01, 100) \n"
        result += "\t token projection = \"perspective\" \n"
                
        result += "}\n"

        return result
    }
}
