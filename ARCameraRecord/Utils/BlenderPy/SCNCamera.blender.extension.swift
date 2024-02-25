//
//  SCNCamera.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import SceneKit
import AVFoundation

extension SCNCamera {
    func toBlenderPyCamera(_ animation: KeyframeAnimation, _ name: String, isVertical: Bool = false) -> String {
        var result = "\n"
        
        result += "bpy.ops.object.camera_add(location=(0, 0, 0))\n"
        
        result += "camera = bpy.context.object\n"
        result += "camera.name = \"\(name)\"\n"
        result += "camera.data.lens = \(self.focalLength / 1.3)\n"  //TODO: calculate right scale
        result += "camera.data.sensor_height = \(self.sensorHeight)\n"
        result += "camera.data.sensor_width = \(self.sensorWidth)\n"
        result += "camera.data.clip_start = 0.1\n"
        result += "camera.data.clip_end = 1000.0\n"
        result += "camera.rotation_mode = 'ZXY'\n"
        
        result += "camera.parent = rootAnchor\n"
        
        result += "bpy.context.scene.camera = camera\n"
        
        result += "camera.animation_data_create()\n"
        result += "camera.animation_data.action = bpy.data.actions.new(name=\"CameraAnimation\")\n"
        
        if let nodeAnimation = animation[name] {
            var index = 0
            var rotations = ""
            var locations = ""
            var keyframes = ""
            
            nodeAnimation.keyTimes.forEach { time in
                let transformMatrix = nodeAnimation.localTransform(atTime: TimeInterval.init(truncating: time))
                
                let position = SIMD3<Float>(transformMatrix.columns.3.x, transformMatrix.columns.3.y, transformMatrix.columns.3.z)

                var rotation = nodeAnimation.rotation(atTime: TimeInterval.init(truncating: time))
                
                if isVertical {
                    rotation.z = rotation.z + Float.pi / 2
                }
                
                if (index > 0) {
                    if (index > 1) {
                        keyframes += ","
                        locations += ","
                        rotations += ","
                    }
                    
                    keyframes += "\(index)"
                    locations += "\(position.toBlenderPy())"
                    rotations += "\(rotation.toBlenderPy())"
                }
                
                index += 1
            }
            
            result += "movement_keyframes = [\(keyframes)]\n"
            result += "locations = [\(locations)]\n"
            result += "rotations = [\(rotations)]\n"
            
        }
        
        
        result += "for i, frame in enumerate(movement_keyframes):\n"
        result += "\tcamera.location = locations[i]\n"
        result += "\tcamera.keyframe_insert(data_path=\"location\", frame=frame)\n"
        result += "\tcamera.rotation_euler = rotations[i]\n"
        result += "\tcamera.keyframe_insert(data_path=\"rotation_euler\", frame=frame)\n"


        return result
    }
    
    var sensorWidth: Double {
        get {
            let fovRadians = (self.fieldOfView * Double.pi) / 180.0  // Convert FOV to radians
            
            return 2 * focalLength * tan(fovRadians / 2)
        }
    }

}
