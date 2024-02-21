//
//  SimpleBackgroundView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.10.23.
//

import SwiftUI

struct SimpleBackgroundView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let backgroundColors: [Color] = [.white, .cyan, .white]
    }
    
    var backgroundColors: [Color]
    
    var body: some View {
        ZStack {
            AngularGradient(colors: backgroundColors,
                            center: .bottomLeading,
                            startAngle: .degrees(180),
                            endAngle: .degrees(360))
        }.frame(width: width, height: height)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SimpleBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleBackgroundView(backgroundColors: [.white, .cyan, .white])
    }
}
