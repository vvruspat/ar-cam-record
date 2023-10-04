//
//  ControlsView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct ControlsView: View {
    @AppStorage(SettingsKeys.showHorizon) var showHorizon = true
    @AppStorage(SettingsKeys.showCrosshair) var showCrosshair = true

    var body: some View {
        ZStack {
            if showCrosshair {
                CrosshairButtonView()
            }
            if showHorizon {
                HorizonControlView()
            }
            HStack(alignment: .center) {
                Spacer()
                ZStack(alignment: .center) {
                    VStack(alignment: .trailing) {
                        AddAnchorButtonView()
                        Spacer()
                    }
                    VStack(alignment: .trailing) {
                        Spacer()
                        RecordButtonView()
                        Spacer()
                    }
                    VStack(alignment: .trailing) {
                        Spacer()
                        SettingsButtonView()
                    }
                }
            }
        }
    }
}

#Preview {
    ControlsView()
}
