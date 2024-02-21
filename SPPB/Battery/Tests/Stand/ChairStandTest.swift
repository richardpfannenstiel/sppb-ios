//
//  ChairStandTest.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import Foundation

struct ChairStandTest: Test {
    
    var title: String
    var instructions: String
    var result: Result?
    var repetitions: Int = 5
    var testType: ChairStandTestType
    
    var maximumTime: Float = 60
    var maximumPoints: Int {
        return 4
    }
    
    func calculatePoints(for time: Float) -> Int {
        switch testType {
        case .single:
            return 0
        case .repeated:
            if time < 11.20 {
                return 4
            }
            if time < 13.70 {
                return 3
            }
            if time < 16.70 {
                return 2
            }
            if time <= 60 {
                return 1
            }
            return 0
        }
    }
    
}
