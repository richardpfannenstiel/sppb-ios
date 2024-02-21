//
//  PoseLandmarkType+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 26.05.23.
//

import Foundation
import MLKit

extension PoseLandmarkType {
    
    func position(for pose: Pose) -> Vision3DPoint {
        pose.landmark(ofType: self).position
    }
    
    var isFootLandmark: Bool {
        return self == .leftAnkle || self == .leftHeel || self == .leftToe || self == .rightAnkle || self == .rightHeel || self == .rightToe
    }
}
