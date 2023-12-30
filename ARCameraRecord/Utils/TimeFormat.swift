//
//  TimeFormat.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 30/12/2023.
//

import Foundation

func formatSecondsToHHMMSS(_ time: Double) -> String {
    let totalSeconds = Int(time)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    let ms = Int((time - Double(totalSeconds)) * 1000)

    let formattedTime = String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, ms)
    
    return formattedTime
}
