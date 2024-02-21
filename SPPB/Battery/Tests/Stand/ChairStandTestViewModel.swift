//
//  ChairStandTestViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 28.07.23.
//

import SwiftUI
import Combine
import MLKit

final class ChairStandTestViewModel: TestViewModel {
    
    // MARK: - Test Progress Stages
    
    internal enum Progress {
        case readingInstructions
        case awaitTakingSit
        case awaitFoldingArms
        case readyToStart
        case testOngoing
        case testStopped
    }
    
    // MARK: - Patient Postures
    
    internal enum Posture: String {
        case sitting = "SITTING"
        case standingUp = "STANDING UP"
        case standingStraight = "STANDING STRAIGHT"
        case sittingDown = "SITTING DOWN"
    }
    
    // MARK: - Stored Properties
    
    @Published var progress: Progress = .readingInstructions
    
    @Published var counter = 0
    @Published var lastPosture: Posture = .sitting
    @Published var sittingHipXCoordinate: CGFloat? = nil
    @Published var hipCoordinateArea: CGFloat? = nil
    
    @Published var remindArmPosition = false
    
    let maxErrors = 10
    var errors: Int = 0
    
//    @Published var imageBounds: CGSize? = nil
    
//    var previewHipCoordinate: CGFloat? {
//        guard let imageCoordinate = sittingHipXCoordinate else {
//            return nil
//        }
//        let multiplier = imageCoordinate / (imageBounds?.width ?? 1920)
//        return UIScreen.main.bounds.height * multiplier
//    }
//
//    var previewHipCoordinateArea: CGFloat? {
//        guard let area = hipCoordinateArea else {
//            return nil
//        }
//        let multiplier = area / (imageBounds?.width ?? 1920)
//        return UIScreen.main.bounds.height * multiplier
//    }
    
    
    // MARK: - Computed Properties
    
    var chairStandTest: ChairStandTest {
        get {
            super.test as! ChairStandTest
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
        case .awaitTakingSit, .awaitFoldingArms, .readyToStart:
            return "Start".localized
        case .testOngoing:
            return "Abort".localized
        case .testStopped:
            return test.wasAborted ? "Select Reason".localized : "Continue".localized
        }
    }
    
    override var nextButtonDisabled: Bool {
        progress == .awaitTakingSit || progress == .awaitFoldingArms
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
            case .awaitTakingSit:
                return
            case .awaitFoldingArms:
                return
            case .readyToStart:
                startTest()
            case .testOngoing:
                stopTest(withComment: ResultReason.manuallyAborted)
            case .testStopped:
                if chairStandTest.result != nil {
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
        setProgress(to: .awaitTakingSit)
    }
    
    func startTest() {
        // Start the timer and set the test progress.
        startTimer()
        setProgress(to: .testOngoing)
    }
    
    func stopTest(withComment comment: ResultReason = .success) {
        stopTimer()
        let points = comment == .manuallyAborted ? 0 : chairStandTest.calculatePoints(for: time)
        let movementAbnormalities = abnormalityDetector.getResult()
        let result = Result(time: time, points: points, comment: comment, movementAbnormalities: movementAbnormalities)
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
            chairStandTest.result = result
            setProgress(to: .testStopped)
        }
    }
    
    func redoTest() {
        resetTimer()
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
            chairStandTest.result = nil
            setProgress(to: .awaitTakingSit)
            
            counter = 0
            lastPosture = .sitting
            sittingHipXCoordinate = nil
            hipCoordinateArea = nil
            
            errors = 0
            remindArmPosition = false
            
            abnormalityDetector.reset()
        }
    }
    
    // MARK: - Timer Functions
    
    override func runOutTimer() {
        // The maximum time has been exceeded, stop the test.
        stopTest(withComment: ResultReason.maximumTimeExeceeded)
    }
    
    // MARK: - Assessment Function
    
    override
    func assess(pose: Pose, in imageBounds: CGSize? = nil) {
        guard [.awaitTakingSit, .awaitFoldingArms, .readyToStart, .testOngoing].contains(progress) else {
            // If instructions still have to be read or the test is stopped, no assessment necessary.
            return
        }
        
        if chairStandTest.testType == .single {
            // Single Chair Stand Test
            if progress == .testOngoing {
                // Test is running.
                scoreBehavior(forPose: pose)
                
                // Call abnormality detector.
                abnormalityDetector.assess(pose: pose)
                
                if isStanding(forPose: pose) {
                    // Patient is standing straight.
                    stopTest()
                }
            } else {
                // Test has not begun, yet.
                if isStanding(forPose: pose) {
                    // Patient is standing, instruct to take a sit.
                    setProgress(to: .awaitTakingSit)
                } else {
                    // Patient is sitting.
                    if !handsAreNearThighs(forPose: pose) {
                        // Update sitting hip coordinate.
                        setHipCoordinate(forPose: pose)
                        
                        // Patient is in the correct start position.
                        setProgress(to: .readyToStart)
                    } else {
                        // Patient has its arms too close to the chair or thighs, instruct accordingly.
                        setProgress(to: .awaitFoldingArms)
                    }
                }
            }
        } else {
            // Repeated Chair Stand Test
            if progress == .testOngoing {
                // Test is running.
                scoreBehavior(forPose: pose)
                
                // Call abnormality detector.
                abnormalityDetector.assess(pose: pose)
                
                switch lastPosture {
                case .sitting:
                    // Patient was sitting.
                    if !isSitting(forPose: pose) {
                        // Patient was sitting but now is no longer, meaning he must be rising up.
                        setPosture(to: .standingUp)
                    }
                case .standingUp:
                    // Patient was rising from the chair.
                    if isStanding(forPose: pose) {
                        // Patient was rising up and no is standing straight.
                        setPosture(to: .standingStraight)
                        increaseCounter()
                    } else {
                        if isSitting(forPose: pose) {
                            // Patient was rising up but now is sitting again, no full repetition performed.
                            setPosture(to: .sitting)
                        }
                    }
                case .standingStraight:
                    // Patient was standing straight.
                    if !isStanding(forPose: pose) {
                        // Patient is no longer standing straight, meaning he must be lowering down.
                        setPosture(to: .sittingDown)
                    }
                case .sittingDown:
                    // Patient was lowering to the chair.
                    if isSitting(forPose: pose) {
                        // Patient was lowering to the chair and is now sitting on it.
                        setPosture(to: .sitting)
                    } else {
                        if isStanding(forPose: pose) {
                            // Patient was lowering and is not standing straigth again, no full repetition performed.
                            setPosture(to: .standingStraight)
                        }
                    }
                }
            } else {
                // Test has not begun, yet.
                if isStanding(forPose: pose) {
                    // Patient is standing, instruct to take a sit.
                    setProgress(to: .awaitTakingSit)
                } else {
                    // Patient is sitting.
                    if !handsAreNearThighs(forPose: pose) {
                        
                        // Update sitting hip coordinate.
                        setHipCoordinate(forPose: pose)
                        
                        // Patient is in the correct start position.
                        setProgress(to: .readyToStart)
                    } else {
                        // Patient has its arms too close to the chair or thighs, instruct accordingly.
                        setProgress(to: .awaitFoldingArms)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func scoreBehavior(forPose pose: Pose) {
        Task { @MainActor in
            if handsAreNearThighs(forPose: pose) {
                errors += 1
                if errors > maxErrors {
                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                        remindArmPosition = true
                    }
                }
            } else {
                errors = max(errors - 1, 0)
                if errors == 0 {
                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                        remindArmPosition = false
                    }
                }
            }
        }
    }
    
    private func setHipCoordinate(forPose pose: Pose) {
        Task { @MainActor in
            sittingHipXCoordinate = hipXPosition(forPose: pose)
            hipCoordinateArea = getHipCoordinateArea(forPose: pose)
        }
    }
    
    private func increaseCounter() {
        Task { @MainActor in
            counter += 1
            if counter >= chairStandTest.repetitions {
                // Required repetitions to complete the test reached, the test can be stopped.
                stopTest()
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
    
    private func setPosture(to posture: Posture) {
        Task { @MainActor in
            self.lastPosture = posture
        }
    }
    
    private func hipXPosition(forPose pose: Pose) -> CGFloat {
        PoseLandmarkType.leftHip.position(for: pose).x.rounded()
    }
    
    private func handsAreNearThighs(forPose pose: Pose) -> Bool {
        let leftHand = PoseLandmarkType.leftIndexFinger.position(for: pose)
        let rightHand = PoseLandmarkType.rightIndexFinger.position(for: pose)
        
        let leftHip = PoseLandmarkType.leftHip.position(for: pose)
        let rightHip = PoseLandmarkType.rightHip.position(for: pose)
        
        return leftHand.x > leftHip.x && rightHand.x > rightHip.x
    }
    
    private func isStanding(forPose pose: Pose) -> Bool {
        let leftHip = PoseLandmarkType.leftHip.position(for: pose)
        let rightHip = PoseLandmarkType.rightHip.position(for: pose)
        let leftKnee = PoseLandmarkType.leftKnee.position(for: pose)
        let rightKnee = PoseLandmarkType.rightKnee.position(for: pose)
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        
        let distanceHipKneeLeft = leftKnee.x - leftHip.x
        let distanceHipKneeRight = rightKnee.x - rightHip.x
        let distanceKneeAnkleLeft = leftAnkle.x - leftKnee.x
        let distanceKneeAnkleRight = rightAnkle.x - rightKnee.x
        
        let hipKneeToKneeAnkleQuotient = min(distanceHipKneeLeft, distanceHipKneeRight) / min(distanceKneeAnkleLeft, distanceKneeAnkleRight)
        return hipKneeToKneeAnkleQuotient > 0.9
    }
    
    private func getHipCoordinateArea(forPose pose: Pose) -> CGFloat {
        let leftToe = PoseLandmarkType.leftToe.position(for: pose)
        let rightToe = PoseLandmarkType.rightToe.position(for: pose)
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        
        let distanceAnkleToeLeft = leftToe.x - leftAnkle.x
        let distanceAnkleToeRight = rightToe.x - rightAnkle.x
        return (min(distanceAnkleToeLeft, distanceAnkleToeRight) * 0.75).rounded()
    }
    
    private func isSitting(forPose pose: Pose) -> Bool {
        guard let area = hipCoordinateArea, let coordinate = sittingHipXCoordinate else {
            return false
        }
        return hipXPosition(forPose: pose) > (coordinate - area)
    }
    
}
