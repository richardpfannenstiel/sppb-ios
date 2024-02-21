//
//  PoseLandmarkFunction.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 16.08.23.
//

import Foundation
import MLKit

class PoseLandmarkFunction {
    
    //  This function has been copied (and partly adjusted) from the Google MLKit Guide for pose classification options.
    //  https://developers.google.com/ml-kit/vision/pose-detection/classifying-poses?hl=en
    
    static func angle(firstLandmark: PoseLandmark, midLandmark: PoseLandmark, lastLandmark: PoseLandmark) -> CGFloat {
        let radians: CGFloat = atan2(lastLandmark.position.y - midLandmark.position.y, lastLandmark.position.x - midLandmark.position.x) - atan2(firstLandmark.position.y - midLandmark.position.y, firstLandmark.position.x - midLandmark.position.x)
        var degrees = radians * 180.0 / .pi
        degrees = abs(degrees)
        
        if degrees > 180.0 {
            degrees = 360.0 - degrees
        }
        return degrees
    }
    
    static func normalizeDistance(distance: CGFloat, for pose: Pose) -> CGFloat {
        return (distance / CGFloat(lowerBodyHeight(for: pose))) * 100
    }
    
    static func lowerBodyHeight(for pose: Pose) -> Int {
        let leftHip = PoseLandmarkType.leftHip.position(for: pose)
        let rightHip = PoseLandmarkType.rightHip.position(for: pose)
        
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        
        let hipHeight = (leftHip.x + rightHip.x) / 2
        let ankleHeight = (leftAnkle.x + rightAnkle.x) / 2
        
        return Int(abs(hipHeight - ankleHeight))
    }
}
