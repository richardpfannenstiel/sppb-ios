//
//  CameraViewController.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 23.05.23.
//
//  Parts of this file have been copied from the MLKit Vision Sample App
//  https://github.com/googlesamples/mlkit/tree/master/ios/quickstarts/vision
//
//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import SwiftUI
import UIKit
import SwiftUI
import MLKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @AppStorage("settings.showingPoseOverlay") var showingPoseOverlay = true
    
    // MARK: - Constants
    
    private enum Constant {
        static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
        static let smallDotRadius: CGFloat = 4.0
        static let lineWidth: CGFloat = 3.0
        static let videoQuality: AVCaptureSession.Preset = .high
    }
    
    // MARK: - Stored Properties
    
    private var isUsingFrontCamera = false
    private var permissionGranted = false
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
    
    
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    
    private var analyzer: PoseAnalyzer
    
    init(_ analyzer: PoseAnalyzer) {
        self.analyzer = analyzer
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        fatalError("Use default initializer.")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check whether permission to use the camera is granted.
        checkPermission()
        
        setupPreviewLayer()
        
        // Setup the input and output feeds.
        setupCaptureSessionOutput()
        setupCaptureSessionInput()
        
        // Add camera preview and pose overlay to the view.
        DispatchQueue.main.async { [self] in
            view.layer.addSublayer(previewLayer)
            view.addSubview(annotationOverlayView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: Setup Methods
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
    }
    
    private func setupCaptureSessionOutput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.beginConfiguration()
            // When performing latency tests to determine ideal capture settings,
            // run the app in 'release' mode to get accurate performance metrics
            strongSelf.captureSession.sessionPreset = Constant.videoQuality
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
            output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
            guard strongSelf.captureSession.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            strongSelf.captureSession.addOutput(output)
            strongSelf.captureSession.commitConfiguration()
        }
    }
    
    private func setupCaptureSessionInput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            let cameraPosition: AVCaptureDevice.Position = strongSelf.isUsingFrontCamera ? .front : .back
            guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                strongSelf.captureSession.beginConfiguration()
                let currentInputs = strongSelf.captureSession.inputs
                for input in currentInputs {
                    strongSelf.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard strongSelf.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                strongSelf.captureSession.addInput(input)
                strongSelf.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
        case .authorized:
            permissionGranted = true
            
            // Permission has not been requested yet
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func showPose(for poses: [Pose], width: CGFloat, height: CGFloat) {
        weak var weakSelf = self
        DispatchQueue.main.sync {
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
                        return strongSelf.normalizedPoint(
                            fromVisionPoint: position, width: width, height: height)
                    }
                )
                strongSelf.annotationOverlayView.addSubview(poseOverlayView)
            }
        }
    }
    
    private func removeDetectionAnnotations() {
        for annotationView in annotationOverlayView.subviews {
            annotationView.removeFromSuperview()
        }
    }
    
    func flipCamera() {
        isUsingFrontCamera.toggle()
        removeDetectionAnnotations()
        setupCaptureSessionInput()
    }
    
    // MARK: - Session Capture Management
    
    private func startSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.stopRunning()
        }
    }
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        if let device = discoverySession.devices.first {
            // Enable auto focus and auto exposure.
            if device.isFocusModeSupported(.continuousAutoFocus) {
                try! device.lockForConfiguration()
                device.isSubjectAreaChangeMonitoringEnabled = true
                device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            return device
        } else {
            return nil
        }
    }
    
    private func convertedPoints(
        from points: [NSValue]?,
        width: CGFloat,
        height: CGFloat
    ) -> [NSValue]? {
        return points?.map {
            let cgPointValue = $0.cgPointValue
            let normalizedPoint = CGPoint(x: cgPointValue.x / width, y: cgPointValue.y / height)
            let cgPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
            let value = NSValue(cgPoint: cgPoint)
            return value
        }
    }
    
    private func normalizedPoint(
        fromVisionPoint point: VisionPoint,
        width: CGFloat,
        height: CGFloat
    ) -> CGPoint {
        let cgPoint = CGPoint(x: point.x, y: point.y)
        var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
        normalizedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
        return normalizedPoint
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        let orientation = PoseOverlayHelper.imageOrientation(
            fromDevicePosition: isUsingFrontCamera ? .front : .back
        )
        
        guard let image = MLImage(sampleBuffer: sampleBuffer) else {
            return
        }
        image.orientation = orientation
        
        let poses = analyzer.assess(image)
        
        // Show the pose overlay if enabled by the user.
        if showingPoseOverlay {
            showPose(for: poses, width: imageWidth, height: imageHeight)
        }
    }
}
