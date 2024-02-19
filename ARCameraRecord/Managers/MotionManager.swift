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
    @Published var roll = 0.0
    static var shared = MotionManager()
    
    private var motionManager: CMMotionManager!
    
    init() {
        motionManager = CMMotionManager()
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) {_,_ in 
            self.update()
        }
    }

    func update() {
        if let deviceMotion = motionManager.deviceMotion {
            self.pitch = deviceMotion.attitude.pitch * (180 / Double.pi)
            self.roll = deviceMotion.attitude.roll * (180 / Double.pi)
        }
    }
}
