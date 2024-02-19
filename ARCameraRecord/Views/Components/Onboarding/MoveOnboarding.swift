//
//  MoveOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct MoveOnboarding: View {
    var orientation: InterfaceOrientation
    
    var body: some View {
        VStack(alignment: .center) {
            if (orientation == .landscapeRight) {
                Spacer()
            }
            
            HStack(alignment: .center) {
                Spacer()
                Image(systemName: "arrow.left.arrow.right.square")
                Text("Move camera to detect planes")
                Spacer()
            }.padding(.bottom, 0.0).foregroundStyle(Color("OnboardingTextColor"))
            
            if (orientation != .landscapeRight) {
                Spacer()
            }
        }
    }
}

#Preview {
    MoveOnboarding(orientation: .landscapeRight)
}
