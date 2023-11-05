//
//  Int.extension.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import Foundation

extension Int: USDAConvertable {
    func toUsda() -> String {
        return "\(self)"
    }
    
    func getUsdaType() -> String {
        return "int"
    }
}
