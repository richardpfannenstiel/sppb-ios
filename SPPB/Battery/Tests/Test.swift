//
//  Test.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 28.06.23.
//

import Foundation

protocol Test {

    var title: String { get set }
    var instructions: String { get set }
    var result: Result? { get set }
    
    var maximumTime: Float { get }
    var maximumPoints: Int { get }
    
    func calculatePoints(for time: Float) -> Int
}

extension Test {
    
    // MARK: - Computed Properties
    
    var id: String {
        title
    }
    
    var isFinished: Bool {
        state != .upcoming
    }
    
    var wasFailed: Bool {
        guard let result = result else {
            return false
        }
        return result.failed
    }
    
    var wasAborted: Bool {
        guard let result = result else {
            return false
        }
        return result.failed && result.comment == .manuallyAborted
    }
    
    var state: TestState {
        guard let result = result else {
            return .upcoming
        }
        return result.skipped ? .skipped : .attempted
    }
    
    // MARK: - Functions
    
    mutating func skip() {
        if result != nil {
            // Test has already been conducted, cannot be skipped.
            return
        }
        result = Result(time: 0, points: 0, comment: ResultReason.skipped, movementAbnormalities: [])
    }
}
