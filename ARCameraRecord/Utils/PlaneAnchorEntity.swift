//
//  PlaneActorEntity.swift
//  ARCamRecord
//
//  Created by Aleksandr Kolesov on 03/10/2023.
//

import Foundation
import RealityKit
import ARKit

class PlaneAnchorEntity: Entity, HasModel, HasAnchoring {
    
    @available(*, unavailable)
    required init() {
        fatalError("Not available")
    }
    
    /// Initialize the AnchorEntity. Model is provided using a ModelComponent while HasAnchoring is implemented by updating transform and mesh directly from ARSession.
    /// Adjust position to center of plane and rotate on Y with provided angle from the Anchor planeExtent.
    init(arPlaneAnchor: ARPlaneAnchor) {
        super.init()
        self.components.set(createModelComponent(arPlaneAnchor))
        self.transform.matrix = arPlaneAnchor.transform
        self.position += arPlaneAnchor.center
        
        if arPlaneAnchor.alignment == .vertical {
            self.orientation = simd_quatf(angle: -.pi/2, axis: [1,0,0])
        }
    }
    
    /// Create a model compontent with a planemesh using the size of the provided ARPlaneAnchor.
    private func createModelComponent(_ arPlaneAnchor: ARPlaneAnchor) -> ModelComponent {
        let mesh = MeshResource.generatePlane(width: arPlaneAnchor.planeExtent.width, depth: arPlaneAnchor.planeExtent.height)
        var material = UnlitMaterial(color: .green.withAlphaComponent(0.5))
        
        material.color = try! .init(tint: .white.withAlphaComponent(0.999),
                                 texture: .init(.load(named: "PlaneTexture")))
        
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        
        return modelComponent
    }
    
    /// Called when the ARsession has updated the anchor. Update the transform and the mesh with provided transform/size.
    /// Adjust position to center of plane and rotate on Y with provided angle from the Anchor planeExtent.
    func didUpdate(arPlaneAnchor: ARPlaneAnchor) throws {
        self.model?.mesh = MeshResource.generatePlane(width: arPlaneAnchor.planeExtent.width, depth: arPlaneAnchor.planeExtent.height)
        self.transform.matrix = arPlaneAnchor.transform
        self.position += arPlaneAnchor.center
    }
}
