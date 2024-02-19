//
//  RecordOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct RecordOnboarding: View {
    var orientation: InterfaceOrientation

    var body: some View {
        VStack(alignment: .center) {
            if (orientation == .landscapeRight) {
                Spacer()
            }
            
            HStack(alignment: .center) {
                Spacer()
                Text("Now you can start recording video and camera movements")
                Spacer()
            }.padding(.bottom, 0.0)
            
            if (orientation != .landscapeRight) {
                Spacer()
            }
        }
    }
}

#Preview {
    RecordOnboarding(orientation: .landscapeRight)
}
