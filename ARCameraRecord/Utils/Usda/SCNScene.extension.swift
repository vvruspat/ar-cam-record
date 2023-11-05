//
//  usda_export.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 26/09/2023.
//

import SceneKit

typealias KeyframeAnimation = [String:MDLTransform]

extension SCNScene {
    func exportToUsda(animation: KeyframeAnimation, fps: Float) -> String {
        var usdaData = "#usda 1.0\n"
        
        usdaData += "(\n"
        usdaData += "\t defaultPrim = \"Light\"\n"
        usdaData += "\t doc = \"ArCamRecord\"\n"
        usdaData += "\t endTimeCode = \(animation["CameraNode"]?.keyTimes.count ?? 1)\n"
        usdaData += "\t metersPerUnit = 1\n"
        usdaData += "\t startTimeCode = 1\n"
        usdaData += "\t timeCodesPerSecond = \(fps)\n"
        usdaData += "\t upAxis = \"Y\"\n"
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

