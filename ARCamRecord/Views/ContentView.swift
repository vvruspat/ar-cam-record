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
    
    @ObservedObject var manager = ARManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            ZStack {
                CrosshairButtonView()
                ControlsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
