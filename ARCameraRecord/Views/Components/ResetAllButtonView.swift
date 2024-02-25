//
//  ResetAllButtonView.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 21/12/2023.
//

import SwiftUI

struct ResetAllButtonView: View {
    @EnvironmentObject var manager: ARManager
    
    var body: some View {
        Button {
            manager.reset()
        } label: {
            Image(systemName: "arrow.clockwise.circle").font(.system(size: 32)).tint(.white)
        }.padding(16).frame( width: 48, height: 48).background(Color("ToolBoxBackground")).clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    ResetAllButtonView()
}
