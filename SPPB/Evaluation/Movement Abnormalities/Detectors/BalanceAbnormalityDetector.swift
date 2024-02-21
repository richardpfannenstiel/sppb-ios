//
//  AbnormalityDetector.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.11.23.
//

import Foundation
import MLKit

class BalanceAbnormalityDetector: AbnormalityDetector {
    
    let elbowBentThreshold: CGFloat = 120
    let armsSpreadOutThreshold: CGFloat = 130
    
    private var totalFramesAssessed: Double = 0
    
    private var framesWithRightArmSpread: Double = 0
    private var framesWithLeftArmSpread: Double = 0
    
    private var framesWithRightArmBent: Double = 0
    private var framesWithLeftArmBent: Double = 0
    
    private var sternumPositions: [CGFloat] = []
    
    private var normalizationPose: Pose? = nil
    
    func getResult() -> [MovementAbnormality] {
        var abnormalities: [BalanceAbnormality] = []
        
        let rightArmBentShare = framesWithRightArmBent / totalFramesAssessed
        let leftArmBentShare = framesWithLeftArmBent / totalFramesAssessed
        
        abnormalities.append(.oneArmConstantlyBent(share: max(rightArmBentShare, leftArmBentShare)))
        abnormalities.append(.rightArmConstantlyBent(share: rightArmBentShare))
        abnormalities.append(.leftArmConstantlyBent(share: leftArmBentShare))
        abnormalities.append(.armsUsedToKeepBalance(share: max(framesWithRightArmSpread / totalFramesAssessed,
                                                               framesWithLeftArmSpread / totalFramesAssessed)))
        if let pose = normalizationPose {
            abnormalities.append(.wobbling(offset: (PoseLandmarkFunction.normalizeDistance(distance: (sternumPositions.max() ?? 0) - (sternumPositions.min() ?? 0), for: pose))))
        }
        print(abnormalities)
        return abnormalities
    }
    
    func assess(pose: Pose) {
        totalFramesAssessed += 1
        
        // Arms being bent.
        if rightArmIsBent(for: pose) {
            framesWithRightArmBent += 1
        }
        if leftArmIsBent(for: pose) {
            framesWithRightArmBent += 1
        }
        
        // Arms spreading.
        if rightArmIsSpreadOut(for: pose) {
            framesWithRightArmSpread += 1
        }
        if leftArmIsSpreadOut(for: pose) {
            framesWithLeftArmSpread += 1
        }
        
        // Upper body position.
        if normalizationPose == nil {
            normalizationPose = pose
        }
        sternumPositions.append(sternumHorizontalPosition(for: pose))
    }
    
    func reset() {
        totalFramesAssessed = 0
        framesWithRightArmSpread = 0
        framesWithLeftArmSpread = 0
        
        framesWithRightArmBent = 0
        framesWithLeftArmBent = 0
        
        sternumPositions = []
        normalizationPose = nil
    }
    
    private func rightArmIsBent(for pose: Pose) -> Bool {
        rightElbowAngle(for: pose) < elbowBentThreshold
    }
    
    private func leftArmIsBent(for pose: Pose) -> Bool {
        leftElbowAngle(for: pose) < elbowBentThreshold
    }
    
    private func rightArmIsSpreadOut(for pose: Pose) -> Bool {
        rightShoulderAngle(for: pose) > armsSpreadOutThreshold
    }
    
    private func leftArmIsSpreadOut(for pose: Pose) -> Bool {
        leftShoulderAngle(for: pose) > armsSpreadOutThreshold
    }
    
    private func rightElbowAngle(for pose: Pose) -> CGFloat {
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let rightElbow = pose.landmark(ofType: .rightElbow)
        let rightWrist = pose.landmark(ofType: .rightWrist)
        return PoseLandmarkFunction.angle(firstLandmark: rightShoulder, midLandmark: rightElbow, lastLandmark: rightWrist)
    }
    
    private func leftElbowAngle(for pose: Pose) -> CGFloat {
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let leftElbow = pose.landmark(ofType: .leftElbow)
        let leftWrist = pose.landmark(ofType: .leftWrist)
        return PoseLandmarkFunction.angle(firstLandmark: leftShoulder, midLandmark: leftElbow, lastLandmark: leftWrist)
    }
    
    private func rightShoulderAngle(for pose: Pose) -> CGFloat {
        let rightElbow = pose.landmark(ofType: .rightElbow)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        return PoseLandmarkFunction.angle(firstLandmark: rightElbow, midLandmark: rightShoulder, lastLandmark: leftShoulder)
    }
    
    private func leftShoulderAngle(for pose: Pose) -> CGFloat {
        let leftElbow = pose.landmark(ofType: .leftElbow)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        return PoseLandmarkFunction.angle(firstLandmark: leftElbow, midLandmark: leftShoulder, lastLandmark: rightShoulder)
    }
    
    private func sternumHorizontalPosition(for pose: Pose) -> CGFloat {
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        return (leftShoulder.position.y + rightShoulder.position.y) / 2
    }
}
