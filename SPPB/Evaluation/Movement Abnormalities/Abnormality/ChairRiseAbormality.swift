//
//  ChairRiseAbormality.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.11.23.
//

import Foundation

enum ChairRiseAbormality: MovementAbnormality {
    case armsNotFoldedAcrossChest(share: CGFloat)
    case armsHeldTooLow(share: CGFloat)
    case feetSpacedHorizontallyApart(distance: CGFloat)
    case feetSpacedVerticallyApart(distance: CGFloat)
    
    var id: String {
        description
    }
    
    var description: String {
        switch self {
        case .armsNotFoldedAcrossChest(let share):
            if isSignificant {
                return "The patient was unable to cross his arms correctly in front of his chest for more than $share% of the time.".localized
                    .replacingOccurrences(of: "$share", with: "\((1 - share).fullPercentage())")
            } else {
                return ""
            }
        case .armsHeldTooLow(let share):
            if isSignificant {
                return "The arms were used illegally for $share% of the time. Perhaps they supporting the patient to stand up.".localized
                    .replacingOccurrences(of: "$share", with: "\(share.fullPercentage())")
            } else {
                return ""
            }
        case .feetSpacedHorizontallyApart:
            return ""
        case .feetSpacedVerticallyApart:
            if isSignificant {
                return "The knee angles of both legs differed significantly during the exercise. The load on the legs is possibly asymmetrical.".localized
            } else {
                return ""
            }
        }
    }
    
    var isSignificant: Bool {
        switch self {
        case .armsNotFoldedAcrossChest(let share):
            return share > 0.2
        case .armsHeldTooLow(let share):
            return share > 0.2
        case .feetSpacedHorizontallyApart:
            return true
        case .feetSpacedVerticallyApart(let distance):
            return distance > 10
        }
    }
}
