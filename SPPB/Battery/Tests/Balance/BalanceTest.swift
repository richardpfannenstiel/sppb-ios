//
//  ChairStandTest.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 28.06.23.
//

import Foundation

struct BalanceTest: Test {
    
    var title: String
    var instructions: String
    var result: Result?
    var pose: BalancePose
    
    var maximumTime: Float = 10
    var maximumPoints: Int {
        switch pose {
        case .side_by_side:
            return 1
        case .semi_tandem:
            return 1
        case .tandem:
            return 2
        }
    }
    
    func calculatePoints(for time: Float) -> Int {
        switch pose {
        case .side_by_side:
            return time < 10 ? 0 : 1
        case .semi_tandem:
            return time < 10 ? 0 : 1
        case .tandem:
            if time < 3 {
                return 0
            }
            if time < 10 {
                return 1
            } else {
                return 2
            }
        }
    }
    
}
