//
//  FlatGlassSettingsButton.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.08.23.
//

import SwiftUI

struct FlatGlassSettingsButton: View {
    
    let action: () -> ()
    let size: CGSize = CGSize(width: 50, height: 50)
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "gear")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .padding()
                .frame(width: size.width, height: size.height)
        }.buttonStyle(FlatGlassCircularButton())
    }
}

struct FlatGlassSettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        FlatGlassSettingsButton(action: {})
    }
}
