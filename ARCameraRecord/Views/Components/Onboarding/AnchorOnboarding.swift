//
//  AnchorOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct AnchorOnboarding: View {
    var body: some View {
        VStack(alignment: .trailing) {
            HStack() {
                Spacer()
                Text("Tap this button to add anchor to scene")
                Image(systemName: "arrow.right")
            }.foregroundStyle(Color("OnboardingTextColor"))
            Spacer()
        }
    }
}

#Preview {
    AnchorOnboarding()
}
