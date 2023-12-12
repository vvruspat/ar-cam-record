//
//  SuccessOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct SuccessOnboarding: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack() {
                Image(systemName: "sparkles")
                Text("You've done!")
            }.foregroundStyle(Color("OnboardingTextColor"))
                .padding(.bottom, 20.0)
        }
       
    }
}

#Preview {
    SuccessOnboarding()
}
