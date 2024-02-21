//
//  RecordingAnalyzerViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 20.09.23.
//

import SwiftUI
import AVKit
import MLKit

final class RecordingAnalyzerViewModel: ViewModel {
    
    // MARK: - Analyzing Stages
    
    internal enum AnalyzingStage {
        case positioning
        case analyzing
        case finished
    }
    
    // MARK: - Stored Properties
    
    @Published var stage: AnalyzingStage = .positioning
    
    // Positioning, scaling, resizing the image.
    @Published var scale: CGFloat = 1
    @Published var lastScale: CGFloat = 0
    @Published var offset: CGSize = .zero
    @Published var lastStoredOffset: CGSize = .zero
    @Published var imageOrientation: Image.Orientation = .up
    @Published var imageDimensions: CGSize = .zero
    
    @Published var positionPreview: Image? = nil
    @Published var analyzerPreview: Image? = nil
    
    @Published var cgImage: CGImage? = nil
    
    // Analyzing the video.
    @Published var analyzingProgress: CGFloat = 0
    @Published var totalVideoFrames = 0
    @Published var framesProcessed = 0
    
    @ObservedObject var model: TestViewModel
    
    // MARK: - Computed Properties
    
    var closeRecordingDisabled: Bool {
        model.inputState == .loadRecording || stage != .positioning
    }
    
    var galleryButtonDisabled: Bool {
        model.inputState == .loadRecording || stage != .positioning
    }
    
    // MARK: - Initializer
    
    init(model: TestViewModel) {
        self.model = model
    }
    
    // MARK: - Functions
    
    func closeRecording() {
        model.closeRecording()
    }
    
    func showGallery() {
        model.showGallery()
    }
    
    func resetResize() {
        scale = 1
        lastScale = 0
        offset = .zero
        lastStoredOffset = .zero
    }
    
    func rotateClockwise() {
        imageOrientation = imageOrientation.rotatedClockwise
        resetResize()
        updatePreview()
    }
    
    func rotateCounterClockwise() {
        imageOrientation = imageOrientation.rotatedCounterClockwise
        resetResize()
        updatePreview()
    }
    
    func flipHorizontally() {
        imageOrientation = imageOrientation.horizontallyFlipped
        updatePreview()
    }
    
    func analyze() {
        guard let cgImage = cgImage else {
            return
        }
        
        model.imageFormat = ImageFormat(scale: scale, offset: offset, dimensions: imageDimensions, orientation: imageOrientation)
        
        if let croppedImage = model.imageFormat!.crop(image: cgImage) {
            withAnimation(.easeInOut) {
                analyzerPreview = Image(from: croppedImage, orientation: imageOrientation)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
                    stage = .analyzing
                    analyzeVideo(at: model.recordingURL!)
                }
            }
        }
    }
    
    func loadPreviewImage() {
        // Erase any previous analyzing results.
        reset()
        
        Task { @MainActor in
            do {
                guard let url = model.recordingURL else {
                    print("COULD NOT FETCH URL")
                    return
                }
                
                let movie: AVURLAsset = AVURLAsset(url: url)
                let track = try await movie.loadTracks(withMediaType: .video)[0]
                let reader = try AVAssetReader(asset: movie)
                let settings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
                let trackOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
                reader.add(trackOutput)
                reader.startReading()
                
                if let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                        print("Failed to get image buffer from sample buffer.")
                        return
                    }
                    
                    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                    let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
                    let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
                    
                    cgImage = ciImage.convert(width: imageWidth, height: imageHeight)
                    imageDimensions = CGSize(width: imageWidth, height: imageHeight)
                    updatePreview()
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func analyzeVideo(at path: URL) {
        Task { @MainActor in
            do {
                let movie: AVURLAsset = AVURLAsset(url: path)
                let track = try await movie.loadTracks(withMediaType: .video)[0]
                totalVideoFrames = await track.totalFrames
                
                let reader = try AVAssetReader(asset: movie)
                let settings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
                let trackOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
                reader.add(trackOutput)
                reader.startReading()
                
                while reader.status == AVAssetReader.Status.reading {
                    if let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                        await processFrame(in: sampleBuffer)
                        updateAnalyzingProgress(with: framesProcessed)
                    } else {
                        finishAnalyzingProgress()
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    private func updateAnalyzingProgress(with framesProcessed: Int) {
        withAnimation(.easeInOut) {
            analyzingProgress = CGFloat(framesProcessed) / CGFloat(totalVideoFrames)
        }
    }
    
    private func finishAnalyzingProgress() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            stage = .finished
            FeedbackGenerator.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            model.playRecording()
        }
    }
    
    private func processFrame(in sampleBuffer: CMSampleBuffer) async {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        
        // Create a Core Graphics image from the buffer and crop it according to the user's positioning.
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let cgImage = ciImage.convert(width: imageDimensions.width, height: imageDimensions.height)
        guard let croppedImage = model.imageFormat!.crop(image: cgImage) else {
            return
        }
        
        // Update the analyzing progress preview image after sixty frames have been evaluated.
        if framesProcessed % 60 == 0 {
            updateAnalyzerPreview(with: croppedImage)
        }
        
        // Generate a MLKitCompatibleImage image from the cropped image and set its orientation.
        guard let image = MLImage(image: UIImage(cgImage: croppedImage)) else {
            return
        }
        image.orientation = imageOrientation.converted
        
        // Analyze the pose in the picture and save it.
        let poses: [Pose] = await model.analyzer.analyze(image)
        
        // Update the properties with the detected poses.
        model.detectedPoses.append(poses)
        framesProcessed += 1
    }
    
    private func updateAnalyzerPreview(with image: CGImage) {
        analyzerPreview = Image(from: image, orientation: imageOrientation)
    }
    
    private func updatePreview() {
        if let image = cgImage {
            withAnimation(.easeInOut) {
                positionPreview = Image(from: CIImage(cgImage: image), width: imageDimensions.width, height: imageDimensions.height, orientation: imageOrientation)
            }
        }
    }
    
    private func reset() {
        model.detectedPoses = []
        
        stage = .positioning
        scale = 1
        lastScale = 0
        offset = .zero
        lastStoredOffset = .zero
        imageOrientation = .up
        imageDimensions = .zero
        positionPreview = nil
        analyzerPreview = nil
        cgImage = nil
        
        analyzingProgress = 0
        totalVideoFrames = 0
        framesProcessed = 0
    }
}
