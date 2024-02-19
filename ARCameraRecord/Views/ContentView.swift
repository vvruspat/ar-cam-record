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

struct ContentView: View {
    
    @EnvironmentObject var manager: ARManager
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ARViewContainer().ignoresSafeArea(.all)
                if manager.orientation == InterfaceOrientation.landscapeRight {
                    ControlsView().padding(.all, 10.0)
                } else {
                    VerticalControlsView().padding(.all, 10.0)
                }
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
