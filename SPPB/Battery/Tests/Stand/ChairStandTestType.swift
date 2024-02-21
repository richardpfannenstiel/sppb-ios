//
//  ChairStandTestType.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 29.07.23.
//

import Foundation

enum ChairStandTestType {
    case single
    case repeated
}

extension ChairStandTestType {
    
    var instructions: String {
        switch self {
        case .single:
            return "Single Chair Stand Instructions Text".localized
        case .repeated:
            return "Repeated Chair Stand Instructions Text".localized
        }
    }
}
