//
//  FloorOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct FloorOnboarding: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Image(systemName: "arrow.left")
                Text("Press button to select highlighted plane as a floor")
                Spacer()
            }.foregroundStyle(Color("OnboardingTextColor"))
            Spacer()
        }
    }
}

#Preview {
    FloorOnboarding()
}
