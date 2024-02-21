//
//  TestFailedReason.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 29.07.23.
//

import Foundation

enum ResultReason: String, CaseIterable {
    case triedButUnable = "Tried but unable"
    case unassistedImpossible = "Participant could not hold position unassisted"
    case instructorUnsafe = "Not attempted, you felt unsafe"
    case participantUnsafe = "Not attempted, participant felt unsafe"
    case participantDoesNotUnderstand = "Participant unable to understand instructions"
    case participantRefused = "Participant refused"
    
    // Automatic comments
    case success = "Test Completed"
    case skipped = "Skipped"
    case manuallyAborted = "Test Aborted"
    case movementDetected = "Movement Detected"
    case armMovementDetected = "Arm Movement Detected"
    case maximumTimeExeceeded = "Maximum Time Exceeded"
    
    static let manualSelectionReasons: [ResultReason] = [.triedButUnable, .unassistedImpossible, .instructorUnsafe, .participantUnsafe, .participantDoesNotUnderstand, .participantRefused]
    
}

extension ResultReason {
    
    var label: String {
        self.rawValue.localized
    }
    
    func feedback(for test: Test) -> String {
        switch self {
        case .triedButUnable:
            return "The participant tried the exercise but was unable to complete it.".localized
        case .unassistedImpossible:
            return "The participant was not able to hold the position unassisted.".localized
        case .instructorUnsafe:
            return "The test was not attempted as the instructor felt unsafe.".localized
        case .participantUnsafe:
            return "The test was not attempted as the participant felt unsafe.".localized
        case .participantDoesNotUnderstand:
            return "The participant was unable to understand the test instructions.".localized
        case .participantRefused:
            return "The participant refused to conduct the test.".localized
        case .skipped:
            return "The test was automatically skipped due to a previous test not being completed sucessfully.".localized
        case .manuallyAborted:
            return "The test was manually aborted after $time seconds.".localized
        case .movementDetected:
            return "The pose was not held long enough.".localized
        case .armMovementDetected:
            return "The arms were not kept folded across the chest.".localized
        case .maximumTimeExeceeded:
            return "The maximum time allowed for this test was exceeded.".localized
        case .success:
            if test is BalanceTest {
                return "The pose was held for more than $time seconds.".localized
            }
            if test is GaitTest {
                return "The gait speed test was completed successfully.".localized
            }
            if test is ChairStandTest {
                return "The chair stand was completed successfully.".localized
            }
            return ""
        }
    }
}
