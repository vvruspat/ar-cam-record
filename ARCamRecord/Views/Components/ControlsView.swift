//
//  ControlsView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct ControlsView: View {
    var body: some View {
        ZStack {
            HorizonControlView()
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
                }
            }
        }
    }
}

#Preview {
    ControlsView()
}
