//
//  TestViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI
import MLKit
import AVKit
import Combine

class TestViewModel: ViewModel {
    
    // MARK: - Stored Properties
    
    let analyzer: Analyzer
    let abnormalityDetector: AbnormalityDetector
    let battery: Battery
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var test: Test
    @Published var time: Float = 0
    @Published var ringPercentange: CGFloat = 0
    @Published var showingReasonSelection = false
    
    @Published var isFlippingCamera = false
    
    @Published var showingGallerySelection = false
    @Published var recordingLoadingProgress: CGFloat?
    @Published var recordingURL: URL? = nil
    
    @Published var inputState: InputState = .camera
    
    @Published var detectedPoses: [[Pose]] = []
    @Published var imageFormat: ImageFormat? = nil
    
    // MARK: - Computed Properties
    
    var nextButtonLabel: String {
        "Property must be overwritten by subclass."
    }

    var nextButtonDisabled: Bool {
        false
    }

    var cameraButtonDisabled: Bool {
        false
    }
    
    var galleryButtonDisabled: Bool {
        false
    }
    
    // MARK: - Initializer Properties
    
    init(_ battery: Battery) {
        self.battery = battery
        self.test = battery.nextTest!
        self.analyzer = Analyzer()
        self.abnormalityDetector = AbnormalityDetectorFactory.build(for: battery.nextTest!)
        
        analyzer.setAssessment(to: assess)
    }
    
    // MARK: - Timer Functions
    
    func startTimer() {
        if !cancellables.isEmpty {
            return
        }
        Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
                if time < test.maximumTime {
                    time += 0.01
                    withAnimation(.easeInOut(duration: 0.5)) {
                        ringPercentange += CGFloat(0.01 / test.maximumTime)
                    }
                } else {
                    runOutTimer()
                }
            }
            .store(in: &cancellables)
    }
    
    func stopTimer() {
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
    
    func resetTimer() {
        time = 0
        withAnimation(.easeInOut(duration: 0.5)) {
            ringPercentange = 0
        }
    }
    
    func runOutTimer() {
        assert(false, "Function must be overwritten by subclass.")
    }
    
    // MARK: - Functions
    
    func flipCamera() {
        isFlippingCamera = true
    }
    
    func showGallery() {
        showingGallerySelection = true
    }
    
    func playRecording() {
        DispatchQueue.main.async { [self] in
            withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
                inputState = .playRecording
            }
        }
    }
    
    func loadRecording() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            inputState = .loadRecording
        }
    }
    
    func updateRecordingLoadingProgress(with progress: Progress) {
        withAnimation(.easeInOut) {
            recordingLoadingProgress = progress.fractionCompleted
        }
    }
    
    func processPickerResult(with result: GalleryPickerResult) {
        if let url = result.url {
            recordingURL = url
            withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
                inputState = .analyzeRecording
            }
        } else {
            // Show some error message.
        }
    }
    
    func closeRecording() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            inputState = .camera
        }
    }
    
    func next() {
        assert(false, "Function must be overwritten by subclass.")
    }
    
    func showFailedReasonSelector() {
        showingReasonSelection = true
    }
    
    func setFailedReason(to reason: ResultReason) {
        let result = Result(time: time, points: test.result?.points ?? 0, comment: reason, movementAbnormalities: [])
        test.result = result
        showingReasonSelection = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
                save()
            }
        }
    }
    
    func assess(pose: Pose, in imageBounds: CGSize? = nil) {
        assert(false, "Function must be overwritten by subclass.")
    }
    
    func save() {
        battery.update(for: test)
    }
}
