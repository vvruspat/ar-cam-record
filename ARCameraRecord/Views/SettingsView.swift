//
//  SettingsView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: ARManager

    @AppStorage(SettingsKeys.showLidar) var showLidar = false
    @AppStorage(SettingsKeys.showHorizon) var showHorizon = true
    @AppStorage(SettingsKeys.showCrosshair) var showCrosshair = true

    var body: some View {
        List {
            Section("HUD") {
                HStack{
                    HStack(alignment: .center) {
                        Image(systemName: "circle.and.line.horizontal")
                    }.frame(width: 32)
                    Toggle(isOn: $showHorizon) {
                        Text("Show horizon level")
                    }
                }
                HStack{
                    HStack(alignment: .center) {
                        Image(systemName: "circle.and.line.horizontal")
                    }.frame(width: 32)
                    Toggle(isOn: $showCrosshair) {
                        Text("Show crosshair")
                    }
                }
            }
        }.navigationBarTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
