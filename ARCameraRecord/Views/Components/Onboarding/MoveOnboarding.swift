//
//  MoveOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct MoveOnboarding: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack(alignment: .center) {
                VStack {
                    Spacer()
                    Image(systemName: "arrow.left.arrow.right.square")
                    Text("Move camera to detect planes")
                }.foregroundStyle(Color("OnboardingTextColor"))
            }.padding(.top, 40.0)
            Spacer()
        }
    }
}

#Preview {
    MoveOnboarding()
}
