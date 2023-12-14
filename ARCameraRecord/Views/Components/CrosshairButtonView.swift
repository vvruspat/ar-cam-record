//
//  CrosshairButtonView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct CrosshairButtonView: View {
    @EnvironmentObject var manager: ARManager
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Button {
                manager.addAnchor()
            } label: {
                VStack {
                    Image(systemName: "plus").font(.system(size: 48)).tint(.white.opacity(0.6))
                    Text(String(format: "%.1f m", manager.distance)).foregroundStyle(Color("DistanceColor"))
                }
            }
            Spacer()
        }
    }
}

#Preview {
    CrosshairButtonView()
}
