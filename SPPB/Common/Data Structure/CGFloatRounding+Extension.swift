//
//  CGFloatRounding+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 17.11.23.
//
//  The extension defined in this file has mainly been copied from Mehul provided in an answer of the following post.
//  https://stackoverflow.com/a/54347186
//

import Foundation

extension CGFloat {
    func round(to places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
    
    func fullPercentage() -> Int {
        Int(self.round(to: 2) * 100)
    }
}
