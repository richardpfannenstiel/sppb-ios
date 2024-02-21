//
//  Image+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 26.09.23.
//

import SwiftUI

extension Image {
    
    init(from cgImage: CGImage, orientation: Image.Orientation) {
        self.init(cgImage, scale: 1, orientation: orientation, label: Text("\(cgImage.hashValue)_\(orientation.rawValue)"))
    }
    
    init(from ciImage: CIImage, width: CGFloat, height: CGFloat, orientation: Image.Orientation) {
        let cgImage = ciImage.convert(width: width, height: height)
        self.init(from: cgImage, orientation: orientation)
    }
}
