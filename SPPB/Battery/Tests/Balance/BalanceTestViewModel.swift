//
//  BalanceTestViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI
import Combine
import MLKit

final class BalanceTestViewModel: TestViewModel {
    
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
    
    @Published var showingAnimation = false
    
    let maxErrors = 5
    var errors: Int = 0
    
    // MARK: - Computed Properties
    
    var balanceTest: BalanceTest {
        get {
            super.test as! BalanceTest
        }
        set {
            Task { @MainActor in
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                    super.test = newValue
                }
            }
        }
    }
    
    override var nextButtonLabel: String {
        switch progress {
        case .readingInstructions:
            return "Continue".localized
        case .findingPose, .readyToStart:
            return "Start".localized
        case .testOngoing:
            return "Abort".localized
        case .testStopped:
            return test.wasAborted ? "Select Reason".localized : "Continue".localized
        }
    }
    
    override var nextButtonDisabled: Bool {
        progress == .findingPose
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
    
    override
    func next() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            switch progress {
            case .readingInstructions:
                readInstructions()
            case .findingPose:
                setProgress(to: .readyToStart)
            case .readyToStart:
                startTest()
            case .testOngoing:
                stopTest(withComment: .manuallyAborted)
            case .testStopped:
                if balanceTest.result != nil {
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
    
    func startTest() {
        startTimer()
        setProgress(to: .testOngoing)
    }
    
    func stopTest(withComment comment: ResultReason = .success) {
        stopTimer()
        let points = comment == .manuallyAborted ? 0 : balanceTest.calculatePoints(for: time)
        let movementAbnormalities = abnormalityDetector.getResult()
        let result = Result(time: time, points: points, comment: comment, movementAbnormalities: movementAbnormalities)
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
            balanceTest.result = result
            setProgress(to: .testStopped)
        }
    }
    
    func redoTest() {
        resetTimer()
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
            balanceTest.result = nil
            setProgress(to: .findingPose)
            
            errors = 0
            abnormalityDetector.reset()
        }
    }
    
    func showAnimation() {
        showingAnimation = true
    }
    
    // MARK: - Timer Functions
    
    override func runOutTimer() {
        stopTest()
    }
    
    // MARK: - Assessment Function
    
    override
    func assess(pose: Pose, in imageBounds: CGSize? = nil) {
        if [.findingPose, .readyToStart, .testOngoing].contains(progress) {
            let poseTaken = balanceTest.pose.isTaken(for: pose)
            
            if poseTaken && progress == .findingPose {
                setProgress(to: .readyToStart)
                return
            }
            
            if !poseTaken && progress == .readyToStart {
                setProgress(to: .findingPose)
                return
            }
            
            if progress == .testOngoing {
                Task { @MainActor in
                    scoreBehavior(for: poseTaken)
                    abnormalityDetector.assess(pose: pose)
                }
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func scoreBehavior(for poseTaken: Bool) {
        if poseTaken {
            errors = max(errors - 1, 0)
        } else {
            errors += 1
            if errors > maxErrors {
                stopTest(withComment: .movementDetected)
            }
        }
    }
    
    private func setProgress(to progress: Progress) {
        Task { @MainActor in
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                self.progress = progress
            }
        }
    }
}
