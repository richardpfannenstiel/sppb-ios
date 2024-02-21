//
//  RestrictionPredictor.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.11.23.
//

import Foundation

class RestrictionPredictor {
    
    let indicativeScore: CGFloat = 20
    let additiveScore: CGFloat = 15
    
    let stepSizeThreshold: CGFloat = 250
    let gaitFalteringThreshold: CGFloat = 150
    let spatialFeetDistanceThreshold: CGFloat = 10
    let horizontalFeetDistanceThreshold: CGFloat = 2
    let armParalysisThreshold: CGFloat = 0.8
    let armBalanceAssistanceThreshold: CGFloat = 0.2
    let balanceWobblingThreshold: CGFloat = 30
    
    private var scores: [SimulatedRestriction? : CGFloat]
    
    init() {
        scores = [nil : 0, .hemiplegia : 0, .parkinson : 0, .frailty : 0]
    }
    
    private func indicative(for restrictions: [SimulatedRestriction?]) {
        restrictions.forEach({ scores[$0]! += indicativeScore })
    }
    
    private func additive(for restrictions: [SimulatedRestriction?]) {
        restrictions.forEach({ scores[$0]! += additiveScore })
    }
    
    private func normalizedScores() -> [SimulatedRestriction? : CGFloat] {
        let total = scores.values.reduce(0, +)
        return scores.mapValues({ ($0 / total).round(to: 2) })
    }
    
    /**
     Provides a  prediction which movement abnormality might have been simulated by the subject performing the battery tests.
     The result is meant for research purposes only and must not be used to diagnose real patients.
     */
    func predict(basedOn abnormalities: [MovementAbnormality]) -> [SimulatedRestriction? : CGFloat] {
        let balanceAbnormalities = abnormalities.compactMap({ $0 as? BalanceAbnormality })
        balanceAbnormalities.forEach {
            switch $0 {
            case .oneArmConstantlyBent(share: let share):
                if share > armParalysisThreshold {
                    indicative(for: [.hemiplegia])
                } else {
                    indicative(for: [nil, .parkinson, .frailty])
                }
            case .armsUsedToKeepBalance(share: let share):
                if share > armBalanceAssistanceThreshold {
                    additive(for: [.frailty])
                }
            case .wobbling(offset: let offset):
                if offset > balanceWobblingThreshold {
                    additive(for: [.frailty])
                }
            default:
                return
            }
        }
        
        let gaitAbnormalities = abnormalities.compactMap({ $0 as? GaitAbnormality })
        gaitAbnormalities.forEach {
            switch $0 {
            case .oneArmConstantlyBent(share: let share):
                if share > armParalysisThreshold {
                    indicative(for: [.hemiplegia])
                } else {
                    indicative(for: [nil, .parkinson, .frailty])
                }
            case .stepSize(max: let stepSize):
                if stepSize < stepSizeThreshold {
                    indicative(for: [.parkinson])
                } else {
                    indicative(for: [nil, .hemiplegia, .frailty])
                }
            case .faltering(offset: let offset):
                if offset > gaitFalteringThreshold {
                    additive(for: [.parkinson, .frailty])
                }
            default:
                return
            }
        }
        
        let chairRiseAbnormalities = abnormalities.compactMap({ $0 as? ChairRiseAbormality })
        chairRiseAbnormalities.forEach {
            switch $0 {
            case .armsNotFoldedAcrossChest(share: let share):
                if share > armParalysisThreshold {
                    additive(for: [.hemiplegia])
                }
            case .feetSpacedVerticallyApart(distance: let distance):
                if distance > spatialFeetDistanceThreshold {
                    indicative(for: [.hemiplegia, .frailty])
                } else {
                    indicative(for: [nil, .parkinson])
                }
            case .feetSpacedHorizontallyApart(distance: let distance):
                if distance < horizontalFeetDistanceThreshold {
                    additive(for: [.parkinson])
                }
            default:
                return
            }
        }
        
        return normalizedScores()
    }
    
}

struct RestrictionPredictorTest {
    
    static func test() {
        let balanceAbnormalities: [BalanceAbnormality] = [.oneArmConstantlyBent(share: 0.3), .armsUsedToKeepBalance(share: 0.0), .oneArmConstantlyBent(share: 0.1), .armsUsedToKeepBalance(share: 0.0), .oneArmConstantlyBent(share: 0.1), .armsUsedToKeepBalance(share: 0.0)]
        let gaitAbnormalities: [GaitAbnormality] = [.oneArmConstantlyBent(share: 0.0), .stepSize(max: 302), .faltering(offset: 500)]
        let chairRiseAbnormalities: [ChairRiseAbormality] = [.armsNotFoldedAcrossChest(share: 0.0), .feetSpacedVerticallyApart(distance: 15), .armsNotFoldedAcrossChest(share: 0.0), .feetSpacedVerticallyApart(distance: 15), .feetSpacedHorizontallyApart(distance: 1.8)]
        
        var abnormalities: [MovementAbnormality] = []
        abnormalities.append(contentsOf: balanceAbnormalities)
        abnormalities.append(contentsOf: gaitAbnormalities)
        abnormalities.append(contentsOf: chairRiseAbnormalities)
        
        let predictor = RestrictionPredictor()
        let predictionResult = predictor.predict(basedOn: abnormalities)
        print(predictionResult)
    }
}
