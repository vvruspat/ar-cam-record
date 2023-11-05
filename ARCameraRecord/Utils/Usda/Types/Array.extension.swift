//
//  Array.extension.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import Foundation

extension Array: USDAConvertable {
    func toUsda() -> String {
        var index = 0
        var result = "{\n"
        
        self.forEach { element in
            if let element = element as? USDAConvertable {
                if (index > 0) {
                    if (index > 1) {
                        result += ",\n"
                    }
                    
                    result += "\(index) : \(UsdaUtils.getPythonPresentation(attr: element))"
                }
                index += 1
            }
        }
        
        result += "}\n"
        
        return result
    }
    
    func getUsdaType() -> String {
        // TODO: now it is unused but later need to add proper type
        return ""
    }
}

