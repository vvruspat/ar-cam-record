//
//  RecordTimeView.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 30/12/2023.
//

import SwiftUI

struct RecordTimeView: View {
    @EnvironmentObject var manager: ARManager

    let currentDate = Date()

    var body: some View {
        HStack {
            Text("\( formatSecondsToHHMMSS(manager.recordingTime - manager.recordingStartTime))")
                .foregroundColor(Color("RecordTimeColor"))
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .font(Font
                    .system(size: 24)
                    .monospaced()
                )
                
        }.background(Color("RecordTimeBackground"))
            .frame(width: 350, height: 32).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    RecordTimeView()
}
