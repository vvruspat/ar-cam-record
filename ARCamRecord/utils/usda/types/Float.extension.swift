//
//  Float.extension.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import Foundation

extension Float: USDAConvertable {
    func toUsda() -> String {
        return "\(self)"
    }
    
    func getUsdaType() -> String {
        return "float"
    }
}
