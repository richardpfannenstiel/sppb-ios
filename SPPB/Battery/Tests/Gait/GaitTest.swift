//
//  GaitTest.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import Foundation

struct GaitTest: Test {
    
    static var counter = 0
    
    static let firstWalkInstructions = "First Gait Speed Instructions Text".localized
    static let subsequentWalkInstructions = "Subsequent Gait Speed Instructions Text".localized
    
    var title: String
    var instructions: String
    var result: Result?
    var distance: Int
    var number: Int
    
    var maximumTime: Float = 60
    var maximumPoints: Int {
        return 4
    }
    
    init(title: String, instructions: String, result: Result? = nil, distance: Int = 4, number: Int? = nil) {
        self.title = title
        self.instructions = instructions
        self.result = result
        self.distance = distance
        
        GaitTest.counter += 1
        if let number = number {
            self.number = number
        } else {
            self.number = GaitTest.counter
        }
        
    }
    
    func calculatePoints(for time: Float) -> Int {
        if time < 4.82 {
            return 4
        }
        if time < 6.20 {
            return 3
        }
        if time < 8.70 {
            return 2
        }
        if time <= 60 {
            return 1
        }
        return 0
    }
    
}
