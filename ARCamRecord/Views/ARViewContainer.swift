//
//  ARViewContainer.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 24/09/2023.
//

import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var manager = ARManager.shared

    func makeUIView(context: Context) -> some UIView {
        return manager.arView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {        
        manager.updateCameraTransform()
    }
}
