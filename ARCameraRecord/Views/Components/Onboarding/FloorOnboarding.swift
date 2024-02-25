//
//  FloorOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct FloorOnboarding: View {
    var orientation: InterfaceOrientation

    var body: some View {
        VStack(alignment: .center) {
            if (orientation == .landscapeRight) {
                Spacer()
            }
            
            HStack(alignment: .center) {
                Spacer()
                Text("Press button to select highlighted plane as a floor")
                Spacer()
            }.padding(.bottom, 0.0).foregroundStyle(Color("OnboardingTextColor"))
            
            if (orientation != .landscapeRight) {
                Spacer()
            }
        }
    }
}

#Preview {
    FloorOnboarding(orientation: .landscapeRight)
}
