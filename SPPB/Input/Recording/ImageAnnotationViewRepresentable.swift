//
//  ImageAnnotationViewRepresentable.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 27.09.23.
//

import SwiftUI
import MLKit

struct ImageAnnotationViewRepresentable: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var imageWidth: CGFloat?
    @Binding var imageHeight: CGFloat?
    @Binding var orientation: UIImage.Orientation?
    @Binding var poses: [Pose]?
    
    func makeUIViewController(context: Context) -> ImageAnnotationViewController {
        return ImageAnnotationViewController()
    }

    func updateUIViewController(_ uiViewController: ImageAnnotationViewController, context: Context) {
        if let image = image, let imageWidth = imageWidth, let imageHeight = imageHeight, let orientation = orientation {
            uiViewController.showImage(image, width: imageWidth, height: imageHeight, orientation: orientation, with: poses)
        }
    }
}
