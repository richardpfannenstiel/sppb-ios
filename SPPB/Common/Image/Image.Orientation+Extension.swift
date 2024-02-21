//
//  Image.Orientation+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 19.09.23.
//

import SwiftUI

extension Image.Orientation {
    
    var rotatedClockwise: Image.Orientation {
        switch self {
        case .up: return .right
        case .upMirrored: return .rightMirrored
        case .down: return .left
        case .downMirrored: return .leftMirrored
        case .left: return .up
        case .leftMirrored: return .upMirrored
        case .right: return .down
        case .rightMirrored: return .downMirrored
        }
    }
    
    var rotatedCounterClockwise: Image.Orientation {
        switch self {
        case .up: return .left
        case .upMirrored: return .leftMirrored
        case .down: return .right
        case .downMirrored: return .rightMirrored
        case .left: return .down
        case .leftMirrored: return .downMirrored
        case .right: return .up
        case .rightMirrored: return .upMirrored
        }
    }
    
    var horizontallyFlipped: Image.Orientation {
        switch self {
        case .up: return .upMirrored
        case .upMirrored: return .up
        case .down: return .downMirrored
        case .downMirrored: return .down
        case .left: return .rightMirrored
        case .rightMirrored: return .left
        case .right: return .leftMirrored
        case .leftMirrored: return .right
        }
    }
    
    var converted: UIImage.Orientation {
        switch self {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .left:
            return .left
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        }
    }
    
    var convertedCG: CGImagePropertyOrientation {
        switch self {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .left:
            return .left
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        }
    }
}
