//
//  AnchorOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct AnchorOnboarding: View {
    var orientation: InterfaceOrientation

    var body: some View {
        VStack(alignment: .center) {
            if (orientation == .landscapeRight) {
                Spacer()
            }
            
            HStack(alignment: .center) {
                Spacer()
                Text("Tap highlighted button to add anchor to scene")
                Spacer()
            }.padding(.bottom, 0.0).foregroundStyle(Color("OnboardingTextColor"))
            
            if (orientation != .landscapeRight) {
                Spacer()
            }
        }
    }
}

#Preview {
    AnchorOnboarding(orientation: .landscapeRight)
}
