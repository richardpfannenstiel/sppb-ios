//
//  CGRect+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 26.05.23.
//

import Foundation

extension CGRect {
    
    /// Returns a `Bool` indicating whether the rectangle's values are valid`.
    func isValid() -> Bool {
        return !(origin.x.isNaN || origin.y.isNaN || width.isNaN || height.isNaN || width < 0 || height < 0)
    }
}
