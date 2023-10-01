//
//  LabeledDivider.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct LabelledDivider: View {

    let angle: Double
    let horizontalPadding: CGFloat
    let color: Color

    init(angle: Double, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.angle = angle
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    var body: some View {
        ZStack {
            Text(String(format: "%.2f˚", angle)).foregroundColor(color.opacity(0.6)).padding(.bottom, 80)
            HStack {
                Spacer().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                line
                Spacer().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                line
                Spacer().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            }.rotationEffect(.degrees(angle))
        }
    }

    var line: some View {
        VStack { Rectangle().foregroundColor(color.opacity(0.6)).frame(height: 2) }.padding(horizontalPadding)
    }
}

#Preview {
    LabelledDivider(angle: 2.34, horizontalPadding: 8, color: .green)
}
