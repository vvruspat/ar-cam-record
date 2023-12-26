//
//  MotionManager.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 01/10/2023.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    @Published var pitch = 0.0
    static var shared = MotionManager()
    
    private var motionManager: CMMotionManager!
    
    init() {
        motionManager = CMMotionManager()
        motionManager.startDeviceMotionUpdates()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.update()
        }
    }

    func update() {
        if let deviceMotion = motionManager.deviceMotion {
            self.pitch = deviceMotion.attitude.pitch * (180 / Double.pi)
        }
    }
}
