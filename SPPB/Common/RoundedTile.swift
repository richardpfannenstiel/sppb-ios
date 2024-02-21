//
//  RoundedTile.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import SwiftUI

struct RoundedTile : ViewModifier {
    
    private var width: CGFloat
    private var height: CGFloat?
    private var backgroundColor: Color
    
    init(width: CGFloat = UIScreen.main.bounds.width - 50, height: CGFloat? = nil, color: Color = .white) {
        self.width = width
        self.height = height
        self.backgroundColor = color
    }
    
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(15)
    }
}

extension View {
    func tile(width: CGFloat = UIScreen.main.bounds.width - 50, height: CGFloat? = nil, color: Color = .white) -> some View {
        self.modifier(RoundedTile(width: width, height: height, color: color))
    }
}
