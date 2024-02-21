//
//  RecordingViewController.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 18.09.23.
//

import SwiftUI
import UIKit
import MLKit

class ImageAnnotationViewController: UIViewController {
    
    @AppStorage("settings.showingPoseOverlay") var showingPoseOverlay = true
    
    // MARK: - Constants
    
    private enum Constant {
        static let smallDotRadius: CGFloat = 4.0
        static let lineWidth: CGFloat = 3.0
    }
    
    // MARK: - Stored Properties
    
    private var previewLayer: UIImageView!
    private var screenRect: CGRect = UIScreen.main.bounds
    
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPreviewLayer()
        
        // Add video preview and pose overlay to the view.
        DispatchQueue.main.async { [self] in
            view.addSubview(previewLayer)
            view.addSubview(annotationOverlayView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: Setup Methods
    
    private func setupPreviewLayer() {
        previewLayer = UIImageView()
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height)
        previewLayer.contentMode = .scaleAspectFill
    }
    
    // MARK: Showing Image
    
    func showImage(_ image: UIImage, width: CGFloat, height: CGFloat, orientation: UIImage.Orientation, with poses: [Pose]?) {
        previewLayer.image = image
        
        if let poses = poses, showingPoseOverlay {
            showDetectionAnnotations(for: poses, width: width, height: height, orientation: orientation)
        }
    }
    
    // MARK: Showing Detections
    
    private func showDetectionAnnotations(for poses: [Pose], width: CGFloat, height: CGFloat, orientation: UIImage.Orientation) {
        weak var weakSelf = self
        guard let strongSelf = weakSelf else {
            print("Self is nil!")
            return
        }
        
        // Remove old pose overlay.
        removeDetectionAnnotations()
        
        // If no poses were detect, do not draw new overlay.
        guard !poses.isEmpty else {
            return
        }
        
        // Draw pose overlay.
        poses.forEach { pose in
            let poseOverlayView = PoseOverlayHelper.createPoseOverlayView(
                forPose: pose,
                inViewWithBounds: strongSelf.previewLayer.bounds,
                lineWidth: Constant.lineWidth,
                dotRadius: Constant.smallDotRadius,
                positionTransformationClosure: { (position) -> CGPoint in
                    // Normalize each point's coordinates according to the image dimensions and orientation.
                    return strongSelf.normalize(
                        fromVisionPoint: position, width: width, height: height, orientation: orientation)
                }
            )
            
            // Mirror and transform the overlay to match the image orientation.
            poseOverlayView.transform = transform(for: orientation)
            
            // Add the overlay to the annotation view.
            strongSelf.annotationOverlayView.addSubview(poseOverlayView)
        }
    }
    
    private func removeDetectionAnnotations() {
        for annotationView in annotationOverlayView.subviews {
            annotationView.removeFromSuperview()
        }
    }
    
    // MARK: Transform and Normalization Functions
    
    private func transform(for orientation: UIImage.Orientation) -> CGAffineTransform {
        switch orientation {
        case .up:
            return CGAffineTransform(scaleX: 1, y: 1);
        case .upMirrored:
            return CGAffineTransform(scaleX: -1, y: 1);
        case .down:
            return CGAffineTransform(scaleX: -1, y: -1);
        case .downMirrored:
            return CGAffineTransform(scaleX: 1, y: -1);
        case .left:
            return CGAffineTransform(scaleX: 1, y: -1);
        case .leftMirrored:
            return CGAffineTransform(scaleX: 1, y: 1);
        case .right:
            return CGAffineTransform(scaleX: -1, y: 1);
        case .rightMirrored:
            return CGAffineTransform(scaleX: -1, y: -1);
        @unknown default:
            fatalError()
        }
    }
    
    private func normalize(
        fromVisionPoint point: VisionPoint,
        width: CGFloat,
        height: CGFloat,
        orientation: UIImage.Orientation
    ) -> CGPoint {
        let cgPoint = CGPoint(x: point.x, y: point.y)
        var normalizedPoint: CGPoint
        
        let scaledImageSize = previewLayer.getScaledImageSize() ?? previewLayer.frame
        let scaledImageXOffset = previewLayer.getScaledImageSize()?.minX ?? 0
        let scaledImageYOffset = previewLayer.getScaledImageSize()?.minY ?? 0
        
        switch orientation {
        case .up, .upMirrored, .down, .downMirrored:
            normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
            normalizedPoint = CGPoint(x: normalizedPoint.x * scaledImageSize.width + scaledImageXOffset,
                                      y: normalizedPoint.y * scaledImageSize.height + scaledImageYOffset)
        case .right, .rightMirrored, .left, .leftMirrored:
            normalizedPoint = CGPoint(x: cgPoint.x / height, y: cgPoint.y / width)
            normalizedPoint = CGPoint(x: normalizedPoint.y * scaledImageSize.height + scaledImageYOffset,
                                      y: normalizedPoint.x * scaledImageSize.width + scaledImageXOffset)
        @unknown default:
            fatalError()
        }
        return normalizedPoint
    }
}
