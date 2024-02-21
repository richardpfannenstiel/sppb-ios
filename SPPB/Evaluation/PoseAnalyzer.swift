//
//  PoseAnalyzer.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import Foundation
import MLKit

protocol PoseAnalyzer {
    
    func assess(_ image: MLImage) -> [Pose]
    func analyze(_ image: MLImage) -> [Pose]
    func analyze(_ image: MLImage) async -> [Pose]
}
