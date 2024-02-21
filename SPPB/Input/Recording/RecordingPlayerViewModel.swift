//
//  RecordingPlayerViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 27.09.23.
//

import SwiftUI
import AVKit
import MLKit
import Combine

final class RecordingPlayerViewModel: ViewModel {
    
    @ObservedObject var model: TestViewModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentImage: UIImage? = nil
    @Published var width: CGFloat? = nil
    @Published var height: CGFloat? = nil
    @Published var orientation: UIImage.Orientation? = nil
    @Published var currentSwiftUIImage: Image? = nil
    @Published var poses: [Pose]? = nil
    
    @Published var playingRecording = false
    @Published var showingPlayerControls = true
    
    var dismissControlsTimer: Timer? = nil
    
    // MARK: - Computed Properties
    
    private var detectedPoses: [[Pose]] {
        model.detectedPoses
    }
    
    var cameraButtonDisabled: Bool {
        model.inputState == .loadRecording
    }
    
    var galleryButtonDisabled: Bool {
        model.inputState == .loadRecording
    }
    
    var nextButtonLabel: String {
        model.nextButtonLabel
    }
    
    var nextButtonDisabled: Bool {
        model.nextButtonDisabled
    }
    
    // MARK: - Initializer
    
    init(model: TestViewModel) {
        self.model = model
    }
    
    // MARK: - Functions
    
    func load() {
        Task { @MainActor in
            do {
                let movie: AVURLAsset = AVURLAsset(url: model.recordingURL!)
                let track = try await movie.loadTracks(withMediaType: .video)[0]
                let reader = try AVAssetReader(asset: movie)
                let settings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
                let rout: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
                reader.add(rout)
                reader.startReading()
                
                var reducedFrameRate = false
                var frameRate = await track.frameRate
                if frameRate > 30 {
                    frameRate = frameRate / 2
                    reducedFrameRate = true
                }
                
                var counter = 0
                
                // Create a timer that shows a new frame overlayed with pose annotations.
                // It publishes depending on the framerate of the original video provided.
                Timer.publish(every: (1 / frameRate), on: .main, in: .common)
                    .autoconnect()
                    .sink { [self] _ in
                        // Playback is paused by the user, do not advance.
                        if !playingRecording {
                            return
                        }
                        
                        if reader.status == .reading {
                            // Get the next frame of the video.
                            if let sbuff = rout.copyNextSampleBuffer() {
                                guard let imageBuffer = CMSampleBufferGetImageBuffer(sbuff) else {
                                    print("Failed to get image buffer from sample buffer.")
                                    return
                                }
                                
                                // Create a Core Graphics image from the buffer and crop it according to the user's positioning.
                                let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                                let cgImage = ciImage.convert(width: (model.imageFormat?.dimensions.width)!, height: (model.imageFormat?.dimensions.height)!)
                                guard let croppedImage = model.imageFormat!.crop(image: cgImage) else {
                                    return
                                }
                                
                                // Update preview image and its properties.
                                currentImage = UIImage(cgImage: croppedImage, scale: model.imageFormat!.scale, orientation: model.imageFormat!.orientation.converted)
                                width = CGFloat(croppedImage.width)
                                height = CGFloat(croppedImage.height)
                                orientation = model.imageFormat?.orientation.converted
                                
                                // Set the correct pose estimates to be visible in the overlay.
                                poses = detectedPoses[counter]
                                
                                // Assess the detected poses.
                                model.analyzer.assess(detectedPoses[counter], in: CGSize(width: width!, height: height!))
                                
                                // Increase the counter, if frames are skipped, load the next sample buffer and discard it.
                                counter += 1
                                if reducedFrameRate {
                                    if rout.copyNextSampleBuffer() != nil {
                                        counter += 1
                                    } else {
                                        // All frames read, stop the playback process.
                                        stop()
                                    }
                                }
                            } else {
                                // All frames read, stop the playback process.
                                stop()
                            }
                        }
                    }.store(in: &cancellables)
            } catch let error {
                print(error)
            }
        }
    }
    
    func play() {
        if cancellables.isEmpty {
            reset()
            load()
        }
        playingRecording = true
        
        // Dismiss playback controls after a few seconds if the user does not actively do so.
        dismissControlsTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [self] timer in
            withAnimation(.easeInOut) {
                showingPlayerControls = false
            }
        }
    }
    
    func stop() {
        pause()
        
        // Cancel the subscription.
        cancellables.first?.cancel()
        cancellables.removeAll()
    }
    
    func pause() {
        playingRecording = false
        
        // Stop the controls from automatically dismissing if the video is paused.
        dismissControlsTimer?.invalidate()
        
        // Make sure that play controls are visible, if the recording is paused through non-user interaction.
        withAnimation(.easeInOut) {
            showingPlayerControls = true
        }
    }
    
    func toggleControls() {
        withAnimation(.easeInOut) {
            showingPlayerControls.toggle()
        }
        if showingPlayerControls && playingRecording {
            dismissControlsTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [self] timer in
                withAnimation(.easeInOut) {
                    showingPlayerControls = false
                }
            }
        } else {
            dismissControlsTimer?.invalidate()
        }
            
    }
    
    func showCamera() {
        model.closeRecording()
    }
    
    func showGallery() {
        model.showGallery()
    }
    
    func next() {
        model.next()
    }
    
    private func reset() {
        currentImage = nil
        width = nil
        height = nil
        orientation = nil
        currentSwiftUIImage = nil
        poses = nil
        playingRecording = false
    }
}
