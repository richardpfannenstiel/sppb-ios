//
//  ItalicText.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.07.23.
//

import SwiftUI

struct ItalicText : ViewModifier {
    
    private var size: CGFloat
    
    init(size: CGFloat = 17) {
        self.size = size
    }
    
    func body(content: Content) -> some View {
        content
            .italic()
            .font(Font.system(size: size))
            .kerning(0.25)
    }
}

extension Text {
    func italic(size: CGFloat = 17) -> some View {
        self.modifier(ItalicText(size: size))
    }
}
