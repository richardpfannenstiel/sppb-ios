//
//  GaitAbnormality.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.11.23.
//

import Foundation

enum GaitAbnormality: MovementAbnormality {
    case rightArmConstantlyBent(share: CGFloat)
    case leftArmConstantlyBent(share: CGFloat)
    case oneArmConstantlyBent(share: CGFloat)
    case stepSize(max: CGFloat)
    case faltering(offset: CGFloat)
    
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
        case .stepSize(max: let stepSize):
            switch stepSize {
            case ..<200:
                return "The maximum step length was exceptionally short during the gait.".localized
            case 200..<250:
                return "The maximum step length was slightly short during the gait.".localized
            case 250..<350:
                return "The step length was average during the gait.".localized
            default:
                return "The step length was well above average during the gait.".localized
            }
        case .faltering(offset: let offset):
            switch offset {
            case ..<125:
                return "The patient covered the course in a straight line.".localized
            case 125..<150:
                return "The patient walked the course, swaying slightly.".localized
            default:
                return "The patient walked slightly in serpentine lines.".localized
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
        case .stepSize:
            return true
        case .faltering:
            return true
        }
    }
}
