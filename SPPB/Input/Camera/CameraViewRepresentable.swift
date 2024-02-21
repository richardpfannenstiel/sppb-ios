//
//  CameraViewRepresentable.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI

struct CameraViewRepresentable: UIViewControllerRepresentable {
    
    @ObservedObject var model: TestViewModel
    
    init(_ model: TestViewModel) {
        self.model = model
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController(model.analyzer)
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if model.isFlippingCamera {
            uiViewController.flipCamera()

            DispatchQueue.main.async {
                model.isFlippingCamera = false
            }
        }
    }
}
