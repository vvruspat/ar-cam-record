//
//  RecordOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct RecordOnboarding: View {
    var body: some View {
        VStack(alignment: .trailing) {
            Spacer()
            HStack() {
                Spacer()
                Text("Now you can start recording video and camera movements")
                Image(systemName: "arrow.up.forward")
            }.foregroundStyle(Color("OnboardingTextColor"))
                .padding(.top, 100.0)
            Spacer()
        }
        
    }
}

#Preview {
    RecordOnboarding()
}
