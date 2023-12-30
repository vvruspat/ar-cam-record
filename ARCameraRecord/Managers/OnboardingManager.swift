//
//  OnboardingManager.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 11/12/2023.
//

import SwiftUI
import TipKit

enum OnboardingSteps {
    case move
    case floor
    case anchor
    case recording
    case record
}

class OnboardingManager: ObservableObject {
    @Published var currentStep: OnboardingSteps?
    
    static var shared = OnboardingManager()
    
    private init() {}
    
    func goToStep(step: OnboardingSteps?) {
        currentStep = step
    }
}

