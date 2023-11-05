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
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ARViewContainer().ignoresSafeArea(.all)
                ControlsView().padding(.top, 10.0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
