//
//  HorizonControlView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct HorizonControlView: View {
    @ObservedObject var motionManager = MotionManager.shared
    
    var body: some View {
        LabelledDivider(angle: -motionManager.pitch, horizontalPadding: 8, color: .green)
    }
}

#Preview {
    HorizonControlView()
}
