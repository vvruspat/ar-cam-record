//
//  SelectFloorButtonView.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 07/11/2023.
//

import SwiftUI
import TipKit

struct SelectFloorButtonView: View {
    @EnvironmentObject var manager: ARManager
    @EnvironmentObject var onboardingManager: OnboardingManager

    var body: some View {
        Button {
            manager.selectFloorPlane()
        } label: {
            Image(systemName: "dot.squareshape.split.2x2").font(.system(size: 32)).tint(.white)
        }.padding(16).frame( width: 48, height: 48)
    }
}

#Preview {
    SelectFloorButtonView()
}

