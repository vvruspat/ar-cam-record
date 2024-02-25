//
//  AddAnchorButtonView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct AddAnchorButtonView: View {
    @EnvironmentObject var manager: ARManager
    @ObservedObject var onboardingManager: OnboardingManager = OnboardingManager.shared

    var body: some View {        
        Button {
            manager.addAnchor()
        } label: {
            Image(systemName: "plus.square.dashed").font(.system(size: 32)).tint(.white)
        }
        .padding(16)
        .frame( width: 48, height: 48)
        .background(Color("ToolBoxBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: Color.green.opacity(onboardingManager.currentStep == .anchor ? 0.8 : 0.0), radius: 4.0)
    }
}

#Preview {
    AddAnchorButtonView()
}
