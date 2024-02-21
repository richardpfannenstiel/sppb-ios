//
//  BackgroundView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 04.07.23.
//

import SwiftUI

struct BackgroundView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let backgroundColors: [Color] = [.white, .cyan, .white]
        static let bubbleColors: [Color] = [.white, .blue]
    }
    
    var body: some View {
        ZStack {
            AngularGradient(colors: Constant.backgroundColors,
                            center: .bottomLeading,
                            startAngle: .degrees(180),
                            endAngle: .degrees(360))
            Circle()
                .fill(LinearGradient(colors: Constant.bubbleColors, startPoint: .top, endPoint: .bottom))
                .frame(width: width / 2.5)
                .offset(x: -width / 2, y: -height / 8)
                .shadow(radius: 20)
            Circle()
                .fill(LinearGradient(colors: Constant.bubbleColors, startPoint: .leading, endPoint: .bottom))
                .frame(width: width / 1.5)
                .offset(x: width / 2, y: height / 8)
                .shadow(radius: 20)
        }.frame(width: width, height: height)
        .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
