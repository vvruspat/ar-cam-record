//
//  VerticalControlsView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct VerticalControlsView: View {
    @AppStorage(SettingsKeys.showHorizon) var showHorizon = true
    @AppStorage(SettingsKeys.showCrosshair) var showCrosshair = true
    @EnvironmentObject var manager: ARManager

    var body: some View {
        ZStack {
            if showCrosshair {
                CrosshairButtonView()
            }
            HStack(alignment: .center) {
                ZStack(alignment: .center) {
                    VStack(alignment: .trailing) {
                        if !manager.isFloorDetected {
                            SelectFloorButtonView()
                        } else {
                            ResetFloorSelectionButtonView()
                        }
                        
                        ResetAllButtonView()
                        
                        Spacer()
                        
                        SettingsButtonView()
                    }
                }
                Spacer()
                
                VStack(alignment: .center) {
                    Spacer()
                    RecordButtonView()
                }
                Spacer()
                
                ZStack(alignment: .center) {
                    VStack(alignment: .trailing) {
                        RotateButtonView()
                        Spacer()
                    }
                    
                    VStack(alignment: .trailing) {
                        Spacer()
                        
                        AddAnchorButtonView()
                    }
                }
            }
        }
    }
}

#Preview {
    VerticalControlsView()
}
