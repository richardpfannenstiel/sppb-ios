//
//  CGImage+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 26.09.23.
//

import SwiftUI

extension CIImage {
    
    func convert(width: CGFloat, height: CGFloat) -> CGImage {
        let context = CIContext(options: nil)
//        context.createCGImage(self, from: CGRect(x: 0, y: 0, width: width, height: height))
        let cgImage = context.createCGImage(self, from: self.extent)!
        return cgImage
    }
}
