//
//  SCNCamera.extension.swift
//  ARCameraRecord
//
//  Created by Aleksandr Kolesov on 15/11/2023.
//

import SceneKit
import AVFoundation

extension SCNCamera {
    func toBlenderPyCamera(_ animation: KeyframeAnimation, _ name: String) -> String {
        var result = "\n"
        
        result += "bpy.ops.object.camera_add(location=(0, 0, 0))\n"
        
        result += "camera = bpy.context.object\n"
        result += "camera.name = \"\(name)\"\n"
        result += "camera.data.lens = \(self.focalLength / 1.3)\n"  //TODO: calculate right scale
        result += "camera.data.sensor_height = \(self.sensorHeight)\n"
        result += "camera.data.sensor_width = \(self.sensorWidth)\n"
        result += "camera.data.clip_start = \(self.zNear)\n"
        result += "camera.data.clip_end = \(self.zFar)\n"
        result += "camera.rotation_mode = 'ZXY'\n"
        
        result += "bpy.context.scene.camera = camera\n"
        
        result += "camera.animation_data_create()\n"
        result += "camera.animation_data.action = bpy.data.actions.new(name=\"CameraAnimation\")\n"
        
        if let nodeAnimation = animation[name] {
            
//            result += "camera.data.background_images.clear()\n"
//            result += "bg_image = camera.data.background_images.new()\n"
//            result += "bg_image.image = background_image\n"
//            result += "bg_image.frame_method = 'STRETCH'\n"
//            result += "bg_image.alpha = 1.0\n"
//            result += "bg_image.scale = 1.0\n"
//            result += "bg_image.image_user.frame_duration = \(nodeAnimation.keyTimes.count)\n"
//            result += "bg_image.image_user.use_auto_refresh = True\n"
//            result += "camera.data.show_background_images = True\n"

            var index = 0
            var rotations = ""
            var locations = ""
            var keyframes = ""
            
            nodeAnimation.keyTimes.forEach { time in
                let transformMatrix = nodeAnimation.localTransform(atTime: TimeInterval.init(truncating: time))
                
                let position = SIMD3<Float>(transformMatrix.columns.3.x, transformMatrix.columns.3.y, transformMatrix.columns.3.z)

                let rotation = nodeAnimation.rotation(atTime: TimeInterval.init(truncating: time))
                
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
