//
//  ChairRiseAbnormalityDetector.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.11.23.
//

import Foundation
import MLKit

class ChairRiseAbnormalityDetector: AbnormalityDetector {
    
    let feetHorizontalDistanceThreshold = 50
    let feetVerticalDistanceThreshold = 10
    
    private var totalFramesAssessed: Double = 0
    
    private var framesWithArmsNotFolded: Double = 0
    private var framesWithHandsTooLow: Double = 0
    
    private var horizontalFeetDistances: [CGFloat] = []
    private var verticalFeetDistances: [CGFloat] = []
    
    func getResult() -> [MovementAbnormality] {
        var abnormalities: [ChairRiseAbormality] = []
        abnormalities.append(.armsNotFoldedAcrossChest(share: framesWithArmsNotFolded / totalFramesAssessed))
        abnormalities.append(.armsHeldTooLow(share: framesWithHandsTooLow / totalFramesAssessed))
        abnormalities.append(.feetSpacedHorizontallyApart(distance: horizontalFeetDistances.average))
        abnormalities.append(.feetSpacedVerticallyApart(distance: verticalFeetDistances.average))
        print(abnormalities)
        return abnormalities
    }
    
    func assess(pose: Pose) {
        totalFramesAssessed += 1
        
        // Arms folded across the chest.
        if !armsAreFolded(forPose: pose) {
            framesWithArmsNotFolded += 1
        }
        
        // Hands are too low possibly supporting the chair rise.
        if handsAreNearThighs(forPose: pose) {
            framesWithHandsTooLow += 1
        }
        
        // Feet distances.
        horizontalFeetDistances.append(horizontalFeetDistance(forPose: pose))
        verticalFeetDistances.append(verticalFeetDistance(forPose: pose))
    }
    
    func reset() {
        totalFramesAssessed = 0
        framesWithArmsNotFolded = 0
        framesWithHandsTooLow = 0
        horizontalFeetDistances = []
        verticalFeetDistances = []
    }
    
    private func armsAreFolded(forPose pose: Pose) -> Bool {
        let leftWrist = PoseLandmarkType.leftWrist.position(for: pose)
        let rightWrist = PoseLandmarkType.rightWrist.position(for: pose)
        return leftWrist.y > rightWrist.y
    }
    
    private func handsAreNearThighs(forPose pose: Pose) -> Bool {
        let leftHand = PoseLandmarkType.leftIndexFinger.position(for: pose)
        let rightHand = PoseLandmarkType.rightIndexFinger.position(for: pose)
        
        let leftHip = PoseLandmarkType.leftHip.position(for: pose)
        let rightHip = PoseLandmarkType.rightHip.position(for: pose)
        
        return leftHand.x > leftHip.x && rightHand.x > rightHip.x
    }
    
    private func horizontalFeetDistance(forPose pose: Pose) -> CGFloat {
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        return PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.y - rightAnkle.y) * (leftAnkle.y - rightAnkle.y)), for: pose)
    }
    
    private func verticalFeetDistance(forPose pose: Pose) -> CGFloat {
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        return PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.x - rightAnkle.x) * (leftAnkle.x - rightAnkle.x)), for: pose)
    }
    
}
