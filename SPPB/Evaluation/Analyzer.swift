//
//  Analyzer.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 03.07.23.
//

import SwiftUI
import MLKit

class Analyzer: PoseAnalyzer {
    
    // MARK: - Stored Properties
    
    private var poseDetector: PoseDetector
    private var assess: ((Pose, CGSize?) -> ())? = nil
    
    // MARK: - Initializer
    
    init() {
        let options = AccuratePoseDetectorOptions()
        poseDetector = PoseDetector.poseDetector(options: options)
    }
    
    // MARK: - Functions
    
    func setAssessment(to assess: @escaping (Pose, CGSize?) -> ()) {
        self.assess = assess
    }
    
    func assess(_ poses: [Pose], in imageBounds: CGSize? = nil) {
        if let assess = assess {
            poses.forEach { pose in
                assess(pose, imageBounds)
            }
        }
    }
    
    func assess(_ image: MLImage) -> [Pose] {
        let poses: [Pose] = analyze(image)
        let imageBounds = CGSize(width: image.width, height: image.height)
        
        if let assess = assess {
            poses.forEach { pose in
                assess(pose, imageBounds)
            }
        }
        return poses
    }
    
    func analyze(_ image: MLImage) async -> [Pose] {
        var poses: [Pose] = []
        do {
            poses = try await poseDetector.process(image)
         } catch let error {
            print("Failed to detect poses with error: \(error.localizedDescription).")
            return []
        }
        return poses
    }
    
    func analyze(_ image: MLImage) -> [Pose] {
        var poses: [Pose] = []
        do {
            poses = try poseDetector.results(in: image)
         } catch let error {
            print("Failed to detect poses with error: \(error.localizedDescription).")
            return []
        }
        return poses
    }
}
