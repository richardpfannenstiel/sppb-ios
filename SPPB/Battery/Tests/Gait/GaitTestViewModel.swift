//
//  GaitTestViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.08.23.
//

import SwiftUI
import Combine
import MLKit

final class GaitTestViewModel: TestViewModel {
    
    // MARK: - Test Progress Stages
    
    internal enum Progress {
        case readingInstructions
        case findingPose
        case readyToStart
        case testOngoing
        case testStopped
    }
    
    // MARK: - Stored Properties
    
    @Published var progress: Progress = .readingInstructions
    
    // MARK: - Computed Properties
    
    var gaitTest: GaitTest {
        get {
            super.test as! GaitTest
        }
        set {
            Task { @MainActor in
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                    super.test = newValue
                }
            }
        }
    }
    
    var timerStarted: Bool {
        time != 0
    }
    
    override var nextButtonLabel: String {
        switch progress {
        case .readingInstructions:
            return "Continue".localized
        case .findingPose:
            return "Force Start".localized
        case .readyToStart:
            return "Start".localized
        case .testOngoing:
            return "Abort".localized
        case .testStopped:
            return test.wasAborted ? "Select Reason".localized : "Continue".localized
        }
    }
    
    override var nextButtonDisabled: Bool {
        false
    }
    
    override var cameraButtonDisabled: Bool {
        progress == .testOngoing || progress == .testStopped
    }
    
    override var galleryButtonDisabled: Bool {
        progress == .testOngoing || progress == .testStopped
    }
    
    // MARK: - Initializer
    
    init(for battery: Battery) {
        super.init(battery)
    }
    
    convenience init(forIndividual test: Test) {
        self.init(for: Battery(tests: [test]))
    }
    
    // MARK: - Functions
    
    override func next() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            switch progress {
            case .readingInstructions:
                readInstructions()
            case .findingPose:
                // If the user deliberately wants to start the test even though the starting position is not found, yet.
                forceStartTest()
            case .readyToStart:
                setProgress(to: .testOngoing)
            case .testOngoing:
                stopTest(withComment: .manuallyAborted)
            case .testStopped:
                if gaitTest.result != nil {
                    if test.wasAborted {
                        // If the test failed due to manual abortion, require the examiner to provide a reason.
                        showFailedReasonSelector()
                    } else {
                        save()
                    }
                }
            }
        }
    }
    
    func readInstructions() {
        setProgress(to: .findingPose)
    }
    
    func forceStartTest() {
        setProgress(to: .testOngoing)
        startTimer()
    }
    
    func stopTest(withComment comment: ResultReason = .success) {
        stopTimer()
        let points = comment == .manuallyAborted ? 0 : gaitTest.calculatePoints(for: time)
        let movementAbnormalities = abnormalityDetector.getResult()
        let result = Result(time: time, points: points, comment: comment, movementAbnormalities: movementAbnormalities)
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
            gaitTest.result = result
            setProgress(to: .testStopped)
        }
    }
    
    func redoTest() {
        resetTimer()
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
            gaitTest.result = nil
            setProgress(to: .findingPose)
            
            abnormalityDetector.reset()
        }
    }
    
    // MARK: - Timer Functions
    
    override func runOutTimer() {
        // The maximum time for the walk has been exceeded, stop the test.
        stopTest(withComment: ResultReason.maximumTimeExeceeded)
    }
    
    // MARK: - Assessment Function
    
    override
    func assess(pose: Pose, in imageBounds: CGSize? = nil) {
        guard [.findingPose, .readyToStart, .testOngoing].contains(progress) else {
            // If instructions still have to be read or the test is stopped, no assessment necessary.
            return
        }
        
        if progress == .testOngoing {
            // Test is running.
            if timerStarted {
                // Call abnormality detector.
                abnormalityDetector.assess(pose: pose)
                
                // Patient has already moved, check if finish line was passed.
                guard let imageBounds = imageBounds else {
                    return
                }
                let leftHeel = PoseLandmarkType.leftHeel.position(for: pose)
                let rightHeel = PoseLandmarkType.rightHeel.position(for: pose)
                
                if leftHeel.x > imageBounds.width * 0.89 || rightHeel.x > imageBounds.width * 0.89 {
                    stopTest()
                }
            } else {
                // Patient was standing still until now, check if he's moving and start the timer.
                if !startPositionTaken(for: pose) {
                    // Start position is no longer taken, start the timer.
                    startTimer()
                }
            }
        } else {
            // Test has not begun, yet.
            if startPositionTaken(for: pose) {
                // The start pose is taken, test may be started.
                setProgress(to: .readyToStart)
            } else {
                // The start pose is not (or no longer) taken, demand the patient to place its feet accordingly.
                setProgress(to: .findingPose)
            }
        }
    }
    
    
    // MARK: - Private Functions
    
    private func setProgress(to progress: Progress) {
        Task { @MainActor in
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                self.progress = progress
            }
        }
    }
    
    private func startPositionTaken(for pose: Pose) -> Bool {
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        let horizontalDistance = PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.y - rightAnkle.y) * (leftAnkle.y - rightAnkle.y)),
                                                                        for: pose)
        let verticalDistance = PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.x - rightAnkle.x) * (leftAnkle.x - rightAnkle.x)),
                                                                      for: pose)
        return verticalDistance < 10 && horizontalDistance < 25
    }
}
