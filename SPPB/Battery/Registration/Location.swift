//
//  Location.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 03.07.23.
//

import Foundation

enum Location: String {
    case medicalFacility = "Medical Facility"
    case home = "Home"
    case nursingHome = "Nursing Home"
}

extension Location {
    
    var label: String {
        self.rawValue.localized
    }
    
    var delay: Int {
        switch self {
        case .medicalFacility:
            return 0
        case .home:
            return 1
        case .nursingHome:
            return 2
        }
    }
}

extension Location: CaseIterable {}
