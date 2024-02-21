//
//  Mirror+Image.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.07.23.
//

import SwiftUI

extension Image {
    
    internal enum ImageFlipValue {
        case horizontally
        case vertically
    }
    
    func flipped(_ value: ImageFlipValue = .horizontally) -> some View {
        if value == .horizontally {
            return self.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        } else {
            return self.rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
        }
        
    }
}
