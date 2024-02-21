//
//  FeedbackGenerator.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 04.07.23.
//

import SwiftUI

class FeedbackGenerator {
    
    static func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
    }
    
    static func success() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
    
    static func warning() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.warning)
    }
    
    static func error() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.error)
    }
}
