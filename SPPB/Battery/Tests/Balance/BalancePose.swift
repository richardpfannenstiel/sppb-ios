//
//  BalancePose.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 03.07.23.
//

import Foundation
import MLKit

enum BalancePose {
    case side_by_side
    case semi_tandem
    case tandem
}

extension BalancePose {
    
    var instructions: String {
        switch self {
        case .side_by_side:
            return "Side-by-Side Instruction Text".localized
        case .semi_tandem:
            return "Semi-Tandem Instruction Text".localized
        case .tandem:
            return "Tandem Instruction Text".localized
        }
    }
    
    var animationResource: URL? {
        switch self {
        case .side_by_side:
            return URL(string: "https://nextcloud.in.tum.de/index.php/s/Rokk2DbxTCtyiZ8/download/side_by_side_animation.mov")
        case .semi_tandem:
            return URL(string: "https://nextcloud.in.tum.de/index.php/s/oeJdJEcW2fonwEb/download/semi_tandem_animation.mov")
        case .tandem:
            return URL(string: "https://nextcloud.in.tum.de/index.php/s/56aM85bdMBYde7p/download/tandem_animation.mov")
        }
    }
    
    func isTaken(for pose: Pose) -> Bool {
        // Ankle landmarks
        let leftAnkle = PoseLandmarkType.leftAnkle.position(for: pose)
        let rightAnkle = PoseLandmarkType.rightAnkle.position(for: pose)
        
        let horizontalDistance = PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.y - rightAnkle.y) * (leftAnkle.y - rightAnkle.y)), for: pose)
        let verticalDistance = PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftAnkle.x - rightAnkle.x) * (leftAnkle.x - rightAnkle.x)), for: pose)
        
        // Toe landmarks
        let leftToe = PoseLandmarkType.leftToe.position(for: pose)
        let rightToe = PoseLandmarkType.rightToe.position(for: pose)
        
        let distanceLeftAnkleToe = PoseLandmarkFunction.normalizeDistance(distance: sqrt((leftToe.y - leftAnkle.y) * (leftToe.y - leftAnkle.y)), for: pose)
        let distanceRightAnkleToe = PoseLandmarkFunction.normalizeDistance(distance: sqrt((rightToe.y - rightAnkle.y) * (rightToe.y - rightAnkle.y)), for: pose)
        let distanceAnkleToe = max(distanceLeftAnkleToe, distanceRightAnkleToe)
        
//        print("VERTICAL: \(verticalDistance)")
//        print("HORIZONTAL: \(horizontalDistance)")
//        print("ANKLE_TOE: \(distanceAnkleToe)")
        
        switch self {
        case .side_by_side:
            // VERTICAL DISTANCE IS IDEALLY ZERO, MUST NOT EXCEED A THRESHOLD.
            // HORIZONTAL DISTANCE MUST BE AS CLOSE AS POSSIBLE, A VALUE OF 25 IS SUFFICIENTLY CLOSE.
            return verticalDistance < 10 && horizontalDistance < 25 && distanceAnkleToe < 10
        case .semi_tandem:
            // VERTICAL DISTANCE MUST BE GREATER THAN 5 TO ENSURE THAT THE FEET ARE NOT SIDE-BY-SIDE.
            // HORIZONTAL DISTANCE SHOULD BE CLOSER THAN FOR THE SIDE-BY-SIDE STAND.
            return verticalDistance > 5 && verticalDistance < 30 && horizontalDistance < 25 && distanceAnkleToe < 10
        case .tandem:
            // VERTICAL DISTANCE MUST BE GREATER THAN 10 TO ENSURE THAT THE FEET ARE SPACED APART.
            // HORIZONTAL DISTANCE SHOULD BE CLOSER THAN FOR THE SEMI-TANDEM STAND, A VALUE OF 10 IS SUFFICIENTLY CLOSE.
            return verticalDistance < 50 && horizontalDistance < 15 && distanceAnkleToe < 10
        }
    }
}
