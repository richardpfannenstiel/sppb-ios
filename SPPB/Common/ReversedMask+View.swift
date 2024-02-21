//
//  ReversedMask+View.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.10.23.
//

import SwiftUI

extension View {
    @inlinable func reverseMask<Mask: View>(alignment: Alignment = .center, @ViewBuilder _ mask: () -> Mask) -> some View {
            self.mask(
                ZStack {
                    Circle()
                        .padding(.all, -100)
                    mask()
                        .blendMode(.destinationOut)
                }
            )
        }
}
