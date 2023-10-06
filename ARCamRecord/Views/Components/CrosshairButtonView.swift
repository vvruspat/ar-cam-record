//
//  CrosshairButtonView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import SwiftUI

struct CrosshairButtonView: View {
    let didTapAnchor: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Button {
                didTapAnchor()
            } label: {
                Image(systemName: "plus").font(.system(size: 48)).tint(.white.opacity(0.6))
            }
            Spacer()
        }
    }
}

#Preview {
    CrosshairButtonView(didTapAnchor: {})
}
