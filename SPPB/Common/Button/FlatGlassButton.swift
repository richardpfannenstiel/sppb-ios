//
//  FlatGlassButton.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 04.07.23.
//

import SwiftUI

struct FlatGlassButton: ButtonStyle {
    
    private var tint: Color?
    
    init(tint: Color? = nil) {
        self.tint = tint
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            FeedbackGenerator.haptic()
        }
        return configuration.label
            .padding(.vertical)
            .foregroundColor(.black)
            .background(.ultraThinMaterial)
            .background(tint.opacity(0.5))
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut, value: configuration.isPressed)
    }
}
