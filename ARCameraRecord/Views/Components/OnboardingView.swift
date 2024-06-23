//
//  OnboardingView.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 12/12/2023.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var onboardingManager = OnboardingManager.shared
    
    @EnvironmentObject var manager: ARManager
    
    var body: some View {
        ZStack() {
            switch onboardingManager.currentStep {
            case .anchor: AnchorOnboarding(orientation: manager.orientation)
            case .move: MoveOnboarding(orientation: manager.orientation)
            case .floor: FloorOnboarding(orientation: manager.orientation)
            case .record: RecordOnboarding(orientation: manager.orientation)
            case .recording: RecordingOnboarding(orientation: manager.orientation)
            case .none: SuccessOnboarding(orientation: manager.orientation)
            }
        }
        .padding(.horizontal, manager.orientation == InterfaceOrientation.portrait ? 60.0 : 0.0)
        .padding(.vertical, 24.0)
    }
}

#Preview {
    OnboardingView()
}
