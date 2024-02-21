//
//  FlatGlassCircularButton.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import SwiftUI

struct FlatGlassCircularButton: ButtonStyle {
    
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
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut, value: configuration.isPressed)
    }
}
