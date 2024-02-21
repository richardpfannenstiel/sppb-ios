//
//  CircularProgress.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.07.23.
//

import SwiftUI
import Combine

struct CircularProgress<Content: View>: View {
    
    let radius: CGFloat
    let textSize: CGFloat
    
    @Binding var ringPercentange: CGFloat
    @Binding var result: Result?
    
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: radius * (1/15), lineCap: .round, lineJoin: .round))
                    .frame(width: radius, height: radius)
                    .foregroundColor((result?.failed ?? false ? Color.red : .blue).opacity(0.2))
                Circle()
                    .trim(from: 0, to: ringPercentange)
                    .stroke(style: StrokeStyle(lineWidth: radius * (1/15), lineCap: .round, lineJoin: .round))
                    .frame(width: radius, height: radius)
                    .foregroundColor((result?.failed ?? false ? Color.red : .blue))
                    .rotationEffect(.degrees(90))
                    .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0.0, y: 1.0, z: 0.0))
                    .overlay(
                        content
                    )
            }
        }
        
    }
}

struct CircularProgress_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgress(radius: 150, textSize: 22, ringPercentange: .constant(0.2), result: .constant(Result(time: 0, points: 0, comment: .success, movementAbnormalities: []))) {
            Text("Hallo")
        }
        CircularProgress(radius: 150, textSize: 22, ringPercentange: .constant(0.55), result: .constant(nil)) {
            Text("Hallo")
        }
    }
}
