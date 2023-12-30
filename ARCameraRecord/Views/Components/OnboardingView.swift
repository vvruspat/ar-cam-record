//
//  OnboardingView.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                switch onboardingManager.currentStep {
                case .anchor: AnchorOnboarding()
                case .move: MoveOnboarding()
                case .floor: FloorOnboarding()
                case .record: RecordOnboarding()
                case .recording: RecordingOnboarding()
                case .none: SuccessOnboarding()
                }
            }
            .frame(width: geometry.size.width - 120, height: geometry.size.height - 44)
            .padding(.horizontal, 60.0)
            .padding(.vertical, 24.0)
        }
    }
}

#Preview {
    OnboardingView()
}
