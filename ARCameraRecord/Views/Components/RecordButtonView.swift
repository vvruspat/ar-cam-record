//
//  RecordButtonView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct RecordButtonView: View {
    @EnvironmentObject var manager: ARManager
    
    var body: some View {
        Button() {
            if (!manager.isRecording) {
                Task {
                    await manager.record()
                }
            } else {
                manager.stopRecording()
            }
        } label: {
            if (manager.isRecording) {
                Image(systemName: "stop.circle").font(.system(size: 56)).tint(.white)
            } else {
                Image(systemName: "circle.fill").font(.system(size: 52)).tint(.red)
            }
        }.frame(width: 56, height: 56)
            .background(manager.isRecording ? .red : .white)
            .clipShape(Circle())
    }
}

#Preview {
    RecordButtonView()
}
