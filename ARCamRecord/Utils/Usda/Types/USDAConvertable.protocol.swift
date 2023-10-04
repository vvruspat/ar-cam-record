//
//  USDAConvertable.protocol.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import Foundation

protocol USDAConvertable {
    func toUsda() -> String
    func getUsdaType() -> String
}
