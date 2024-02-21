//
//  GaitAbnormalityDetector.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 14.11.23.
//

import Foundation
import MLKit

class GaitAbnormalityDetector: AbnormalityDetector {
    
    let elbowBentThreshold: CGFloat = 120
    
    private var totalFramesAssessed: Double = 0
    
    private var framesWithRightArmBent: Double = 0
    private var framesWithLeftArmBent: Double = 0
    
    private var maxStepSize: CGFloat = 0
    private var sternumPositions: [CGFloat] = []
    private var horizontalFeetDistances: [CGFloat] = []
    
    private var normalizationPose: Pose? = nil
    
    func getResult() -> [MovementAbnormality] {
        var abnormalities: [GaitAbnormality] = []
        
        let rightArmBentShare = framesWithRightArmBent / totalFramesAssessed
        let leftArmBentShare = framesWithLeftArmBent / totalFramesAssessed
        
        abnormalities.append(.oneArmConstantlyBent(share: max(rightArmBentShare, leftArmBentShare)))
        abnormalities.append(.rightArmConstantlyBent(share: rightArmBentShare))
        abnormalities.append(.leftArmConstantlyBent(share: leftArmBentShare))
        abnormalities.append(.stepSize(max: maxStepSize))
        
        if let pose = normalizationPose {
            abnormalities.append(.faltering(offset: (PoseLandmarkFunction.normalizeDistance(distance: (sternumPositions.max() ?? 0) - (sternumPositions.min() ?? 0), for: pose))))
        }
        print(abnormalities)
        return abnormalities
    }
    
    func assess(pose: Pose) {
        totalFramesAssessed += 1
        
        // Arms being bent.
        if rightArmIsBent(forPose: pose) {
            framesWithRightArmBent += 1
        }
        if leftArmIsBent(forPose: pose) {
            framesWithRightArmBent += 1
        }
        
        // Feet distance.
        let stepSize = spatialFeetDistance(forPose: pose)
        maxStepSize = max(maxStepSize, stepSize)
        
        let horizontalFeetDistance = horizontalFeetDistance(forPose: pose)
        horizontalFeetDistances.append(horizontalFeetDistance)
        
        // Upper body position.
        sternumPositions.append(sternumHorizontalPosition(forPose: pose))
        
        // Use the pose for normalization as the patient is standing as close as possible.
        normalizationPose = pose
    }
    
    func reset() {
        totalFramesAssessed = 0
        
        framesWithRightArmBent = 0
        framesWithLeftArmBent = 0
        
        maxStepSize = 0
        horizontalFeetDistances = []
        sternumPositions = []
        normalizationPose = nil
    }
    
    private func rightArmIsBent(forPose pose: Pose) -> Bool {
        rightElbowAngle(forPose: pose) < elbowBentThreshold
    }
    
    private func leftArmIsBent(forPose pose: Pose) -> Bool {
        leftElbowAngle(forPose: pose) < elbowBentThreshold
    }
    
    private func rightElbowAngle(forPose pose: Pose) -> CGFloat {
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let rightElbow = pose.landmark(ofType: .rightElbow)
        let rightWrist = pose.landmark(ofType: .rightWrist)
        return PoseLandmarkFunction.angle(firstLandmark: rightShoulder, midLandmark: rightElbow, lastLandmark: rightWrist)
    }
    
    private func leftElbowAngle(forPose pose: Pose) -> CGFloat {
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let leftElbow = pose.landmark(ofType: .leftElbow)
        let leftWrist = pose.landmark(ofType: .leftWrist)
        return PoseLandmarkFunction.angle(firstLandmark: leftShoulder, midLandmark: leftElbow, lastLandmark: leftWrist)
    }
    
    private func spatialFeetDistance(forPose pose: Pose) -> CGFloat {
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        return PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.z - rightAnkle.z) * (leftAnkle.z - rightAnkle.z)), for: pose)
    }
    
    private func horizontalFeetDistance(forPose pose: Pose) -> CGFloat {
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        return PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.y - rightAnkle.y) * (leftAnkle.y - rightAnkle.y)), for: pose)
    }
    
    private func hipKneeToKneeAnkleQuotientLeft(forPose pose: Pose) -> CGFloat {
        let leftHip = PoseLandmarkType.leftHip.position(for: pose)
        let leftKnee = PoseLandmarkType.leftKnee.position(for: pose)
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        
        let distanceHipKneeLeft = leftKnee.x - leftHip.x
        let distanceKneeAnkleLeft = leftAnkle.x - leftKnee.x
        
        return distanceHipKneeLeft / distanceKneeAnkleLeft
    }
    
    private func hipKneeToKneeAnkleQuotientRight(forPose pose: Pose) -> CGFloat {
        let rightHip = PoseLandmarkType.rightHip.position(for: pose)
        let rightKnee = PoseLandmarkType.rightKnee.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        
        let distanceHipKneeRight = rightKnee.x - rightHip.x
        let distanceKneeAnkleRight = rightAnkle.x - rightKnee.x
        
        return distanceHipKneeRight / distanceKneeAnkleRight
    }
    
    private func leftKneeAngle(forPose pose: Pose) -> CGFloat {
        let leftHip = pose.landmark(ofType: .leftHip)
        let leftKnee = pose.landmark(ofType: .leftKnee)
        let leftAnkle = pose.landmark(ofType: .leftAnkle)
        
        return PoseLandmarkFunction.angle(firstLandmark: leftHip, midLandmark: leftKnee, lastLandmark: leftAnkle)
    }
    
    private func rightKneeAngle(forPose pose: Pose) -> CGFloat {
        let rightHip = pose.landmark(ofType: .rightHip)
        let rightKnee = pose.landmark(ofType: .rightKnee)
        let rightAnkle = pose.landmark(ofType: .rightAnkle)
        
        return PoseLandmarkFunction.angle(firstLandmark: rightHip, midLandmark: rightKnee, lastLandmark: rightAnkle)
    }
    
    private func sternumHorizontalPosition(forPose pose: Pose) -> CGFloat {
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        return PoseLandmarkFunction.normalizeDistance(distance: (leftShoulder.position.y + rightShoulder.position.y) / 2, for: pose)
    }
}
