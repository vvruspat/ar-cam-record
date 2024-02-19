//
//  SuccessOnboarding.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct RecordingOnboarding: View {
    var orientation: InterfaceOrientation
    
    var body: some View {
        VStack(alignment: .center) {
            if (orientation == .landscapeRight) {
                Spacer()
            }
            
            HStack(alignment: .center) {
                Spacer()
                RecordTimeView()
                Spacer()
            }
            
            if (orientation == .portrait) {
                Spacer()
            }
        }
    }
}

#Preview {
    RecordingOnboarding(orientation: .landscapeRight)
}
