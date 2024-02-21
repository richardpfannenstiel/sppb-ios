//
//  ArrayAverage+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.11.23.
//
//  The extension defined in this file has mainly been copied from Bilaal Rashid provided in an answer of the following post.
//  https://stackoverflow.com/a/62489075
//

import Foundation

extension Array where Element: BinaryFloatingPoint {
    
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }
}
