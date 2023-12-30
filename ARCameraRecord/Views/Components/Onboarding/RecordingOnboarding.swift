//
//  SuccessOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct RecordingOnboarding: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack() {
                RecordTimeView()
            }.padding(.bottom, 0.0)
        }
       
    }
}

#Preview {
    RecordingOnboarding()
}
