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
    let manager = ARManager.shared

    var body: some View {
        ZStack {
            if showCrosshair {
                CrosshairButtonView(didTapAnchor: didTapAnchor)
            }
            if showHorizon {
                HorizonControlView()
            }
            HStack(alignment: .center) {
                Spacer()
                ZStack(alignment: .center) {
                    VStack(alignment: .trailing) {
                        AddAnchorButtonView(didTapAnchor: didTapAnchor)
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

    private func didTapAnchor() {
        manager.addAnchor()
    }
}

#Preview {
    ControlsView()
}
