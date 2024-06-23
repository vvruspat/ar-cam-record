//
//  SettingsButtonView.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import SwiftUI

struct SettingsButtonView: View {
    var body: some View {
        NavigationLink {
            SettingsView()
        } label: {
            Image(systemName: "slider.horizontal.3").font(.system(size: 32)).tint(.white)
        }.padding(16).frame( width: 48, height: 48).background(Color("ToolBoxBackground")).clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    SettingsButtonView()
}
