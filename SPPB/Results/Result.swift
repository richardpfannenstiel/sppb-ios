//
//  Result.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 03.07.23.
//

import Foundation

struct Result {
    
    let time: Float
    let points: Int
    let comment: ResultReason
    let movementAbnormalities: [MovementAbnormality]
    
    
    var skipped: Bool {
        return comment == .skipped
    }
    
    var failed: Bool {
        points == 0 && comment != ResultReason.success
    }
    
}
