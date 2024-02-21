//
//  TranslatedText.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 16.08.23.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
