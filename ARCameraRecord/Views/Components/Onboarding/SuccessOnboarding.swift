//
//  SuccessOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 30/12/2023.
//

import SwiftUI

struct SuccessOnboarding: View {
    var orientation: InterfaceOrientation
    
    var body: some View {
        VStack(alignment: .center) {
            if (orientation == .landscapeRight) {
                Spacer()
            }
            
            HStack(alignment: .center) {
                Spacer()
                Text("Done!")
                Spacer()
            }.padding(.bottom, 0.0).foregroundStyle(Color("OnboardingTextColor"))
            
            if (orientation != .landscapeRight) {
                Spacer()
            }
        }
    }
}

#Preview {
    SuccessOnboarding(orientation: .landscapeRight)
}
