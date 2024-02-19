//
//  RotateButtonView.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 17/02/2024.
//

import SwiftUI

struct RotateButtonView: View {
    @EnvironmentObject var manager: ARManager

    var body: some View {
        Button {
            manager.setOrientation(manager.orientation == InterfaceOrientation.portrait ? InterfaceOrientation.landscapeRight : InterfaceOrientation.portrait)
            manager.setup()
        } label: {
            Image(systemName: manager.orientation == InterfaceOrientation.portrait ? "rectangle.landscape.rotate" : "rectangle.portrait.rotate").font(.system(size: 32)).tint(.white)
        }.padding(16).frame( width: 48, height: 48).background(Color("ToolBoxBackground")).clipShape(RoundedRectangle(cornerRadius: 4)).disabled(manager.isRecording)
    }
}

#Preview {
    RotateButtonView()
}
