//
//  AbnormalityDetector.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.11.23.
//

import Foundation
import MLKit

protocol AbnormalityDetector {
    
    func assess(pose: Pose)
    func getResult() -> [MovementAbnormality]
    func reset()
}

class AbnormalityDetectorFactory {
    
    static func build(for test: Test) -> AbnormalityDetector {
        if test is BalanceTest {
            return BalanceAbnormalityDetector()
        }
        if test is GaitTest {
            return GaitAbnormalityDetector()
        }
        if test is ChairStandTest {
            return ChairRiseAbnormalityDetector()
        }
        
        // Add detectors for new test types.
        fatalError("Not implemented.")
    }
}
