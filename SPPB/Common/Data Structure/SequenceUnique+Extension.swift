//
//  SequenceUnique+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 18.11.23.
//
//  The extension defined in this file has mainly been copied from Jean-Philippe Pellet provided in an answer of the following post.
//  https://stackoverflow.com/a/25739498
//


import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter{ set.insert($0).inserted }
    }
}
