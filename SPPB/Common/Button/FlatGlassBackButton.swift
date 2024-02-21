//
//  BackButton.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI

struct FlatGlassBackButton: View {
    
    let action: () -> ()
    let size: CGSize = CGSize(width: 50, height: 50)
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .padding()
                .frame(width: size.width, height: size.height)
        }.buttonStyle(FlatGlassCircularButton())
    }
}

struct FlatGlassBackButton_Previews: PreviewProvider {
    static var previews: some View {
        FlatGlassBackButton(action: {})
    }
}
