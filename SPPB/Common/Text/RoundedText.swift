//
//  RoundedText.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 04.07.23.
//

import SwiftUI

struct RoundedText : ViewModifier {
    
    private var size: CGFloat
    private var weight: Font.Weight
    
    init(size: CGFloat = 17, weight: Font.Weight = .regular) {
        self.size = size
        self.weight = weight
    }
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: size, weight: weight, design: .rounded))
            .kerning(0.25)
    }
}

extension Text {
    func rounded(size: CGFloat = 17, weight: Font.Weight = .regular) -> some View {
        self.modifier(RoundedText(size: size, weight: weight))
    }
}
