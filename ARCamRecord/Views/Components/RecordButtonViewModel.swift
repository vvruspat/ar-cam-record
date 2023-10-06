//
//  RecordButtonViewModel.swift
//  ARCamRecord
//
//  Created by Ugur Unlu on 06/10/2023.
//

import Foundation

class RecordButtonViewModel: ObservableObject, ARManagerProtocol {
    @Published var isRecording = false

    private let manager: ARManager

    init(manager: ARManager) {
        self.manager = manager
        self.manager.delegate = self
    }

    // MARK: - Helpers
    
    func record() {
        Task {
            await manager.record()
        }
    }

    func stopRecording() {
        manager.stopRecording()
    }

    // MARK: - ARManagerProtocol

    func updateRecording(isRecording: Bool) {
        self.isRecording = isRecording
    }
}
