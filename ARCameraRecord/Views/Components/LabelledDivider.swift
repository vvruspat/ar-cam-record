//
//  LabeledDivider.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct LabelledDivider: View {

    let animationSpeed = 0.3
    let angle: Double
    let horizontalPadding: CGFloat
    var color: Color {
        get {
            if (-2...2).contains(angle) {
                return Color("LevelSuccessColor")
            } else if (-12...12).contains(angle) {
                return Color("LevelWarningColor")
            } else {
                return Color("LevelDangerColor")
            }
        }
    }

    init(angle: Double, horizontalPadding: CGFloat = 20) {
        self.angle = angle
        self.horizontalPadding = horizontalPadding
    }

    var body: some View {
        ZStack {
            if #available(iOS 16.0, *) {
                Text(String(format: "%.2f˚", angle))
                    .padding(.bottom, 80)
                    .foregroundColor(color)
                    .animation(Animation.easeInOut(duration: animationSpeed), value: color)
                    .fontWeight(.bold)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
            } else {
                Text(String(format: "%.2f˚", angle))
                    .padding(.bottom, 80)
                    .foregroundColor(color)
                    .animation(Animation.easeInOut(duration: animationSpeed), value: color)
                    .font(Font.title.weight(.bold))
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
            }
                HStack {
                Spacer().frame(width: 100)
                line
                Spacer().frame(width: 100)
                line
                Spacer().frame(width: 100)
            }.rotationEffect(.degrees(angle))
                .animation(Animation.easeInOut(duration: animationSpeed), value: angle)
        }
    }

    var line: some View {
        VStack { Rectangle()
            .frame(height: 2) }
        .padding(horizontalPadding)
        .foregroundColor(color.opacity(0.6))
        .animation(Animation.easeInOut(duration: animationSpeed), value: color)
    }
}

#Preview {
    LabelledDivider(angle: 2.34, horizontalPadding: 8)
}
