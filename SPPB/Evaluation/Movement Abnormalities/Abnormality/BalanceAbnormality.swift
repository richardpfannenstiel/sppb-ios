//
//  BalanceAbnormality.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.11.23.
//

import Foundation

enum BalanceAbnormality: MovementAbnormality {
    case rightArmConstantlyBent(share: CGFloat)
    case leftArmConstantlyBent(share: CGFloat)
    case oneArmConstantlyBent(share: CGFloat)
    case armsUsedToKeepBalance(share: CGFloat)
    case wobbling(offset: CGFloat)
    
    var id: String {
        description
    }
    
    var description: String {
        switch self {
        case .rightArmConstantlyBent(let share):
            if isSignificant {
                return "The right arm (from an observer's perspective) was significantly bent more than $share% of the time.".localized
                    .replacingOccurrences(of: "$share", with: "\(share.fullPercentage())")
            } else {
                return ""
            }
        case .leftArmConstantlyBent(let share):
            if isSignificant {
                return "The left arm (from an observer's perspective) was significantly bent more than $share% of the time.".localized
                    .replacingOccurrences(of: "$share", with: "\(share.fullPercentage())")
            } else {
                return ""
            }
        case .oneArmConstantlyBent:
            if isSignificant {
                return ""
            } else {
                return "Both arms were kept hanging straight for most of the time.".localized
            }
        case .armsUsedToKeepBalance(let share):
            if isSignificant {
                return "The patient used their arms $share% of the time to keep the balance.".localized
                    .replacingOccurrences(of: "$share", with: "\(share.fullPercentage())")
            } else {
                return "The patient didn't need their arms to hold the balance pose.".localized
            }
        case .wobbling(let offset):
            switch offset {
            case ..<10:
                return "They hardly moved at all during the exercise.".localized
            case 10..<20:
                return "They occasionally swayed slightly during the exercise.".localized
            default:
                return "They wobbled noticeably during the exercise.".localized
            }
        }
    }
    
    var isSignificant: Bool {
        switch self {
        case .rightArmConstantlyBent(let share):
            return share > 0.3
        case .leftArmConstantlyBent(let share):
            return share > 0.3
        case .oneArmConstantlyBent(let share):
            return share > 0.3
        case .armsUsedToKeepBalance(let share):
            return share > 0.2
        case .wobbling(let offset):
            return offset > 20
        }
    }
}
