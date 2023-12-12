//
//  ContentView.swift
//  ARCamRecord
//
//  Created by Елена Белова on 28/07/2023.
//

import SwiftUI
import RealityKit
import SceneKit
import MetalKit
import ModelIO
import TipKit

struct ContentView: View {
    init() {
        try? Tips.resetDatastore()
        try? Tips.configure()
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ARViewContainer().ignoresSafeArea(.all)
                ControlsView().padding(.top, 10.0)
                OnboardingView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
