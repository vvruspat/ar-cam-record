//
//  ResetFloorSelectionButtonView.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 07/11/2023.
//

import SwiftUI

struct ResetFloorSelectionButtonView: View {
    @EnvironmentObject var manager: ARManager
    
    var body: some View {
        Button {
            manager.resetFloorSelection()
        } label: {
            Image(systemName: "squareshape.split.2x2.dotted").font(.system(size: 32)).tint(.white)
        }.padding(16).frame( width: 48, height: 48)
    }
}

#Preview {
    ResetFloorSelectionButtonView()
}
