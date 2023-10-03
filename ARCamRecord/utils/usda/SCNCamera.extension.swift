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
