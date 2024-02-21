//
//  FlatSolidButton.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 12.07.23.
//

import SwiftUI

struct FlatSolidButton: ButtonStyle {
    
    private var color: Color
    
    init(color: Color = .white) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            FeedbackGenerator.haptic()
        }
        return configuration.label
            .padding(.vertical)
            .foregroundColor(.black)
            .background(color)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut, value: configuration.isPressed)
    }
}
