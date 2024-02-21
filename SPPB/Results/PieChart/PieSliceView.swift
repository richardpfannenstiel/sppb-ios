//
//  PieSliceView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 12.10.23.
//
//  The structure defined in this file has mainly been copied from Nazar Ilamanov provided in the following Medium article.
//  https://betterprogramming.pub/build-pie-charts-in-swiftui-822651fbf3f2
//

import SwiftUI

struct PieSliceView: View {
    
    // MARK: - Stored Properties
    
    var pieSlice: PieSlice
    
    // MARK: - Computed Properties
    
    var midRadians: Double {
        return Double.pi / 2.0 - (pieSlice.startAngle + pieSlice.endAngle).radians / 2.0
    }
    
    let glassLook: Bool
    
    init(pieSlice: PieSlice, glassLook: Bool = true) {
        self.pieSlice = pieSlice
        self.glassLook = glassLook
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    path.move(
                        to: CGPoint(
                            x: width * 0.5,
                            y: height * 0.5
                        )
                    )
                    
                    path.addArc(center: CGPoint(x: width * 0.5, y: height * 0.5), radius: width * 0.5, startAngle: Angle(degrees: -90.0) + pieSlice.startAngle, endAngle: Angle(degrees: -90.0) + pieSlice.endAngle, clockwise: false)
                    
                }.fill(pieSlice.color)
                
                if let text = pieSlice.text {
                    ZStack {
                        if glassLook {
                            Text(text)
                                .rounded(weight: .semibold)
                                .foregroundColor(.black)
                                .padding(.all, 10)
                                .background(.ultraThinMaterial)
                                .background(.white.opacity(0.1))
                        } else {
                            Text(text)
                                .rounded(weight: .semibold)
                                .foregroundColor(.white)
                                .padding(.all, 10)
                                .background(.gray)
                        }
                    }
                    .cornerRadius(50)
                    .position(
                        x: geometry.size.width * 0.5 * CGFloat(1.0 + 1 * cos(midRadians)),
                        y: geometry.size.height * 0.5 * CGFloat(1.0 - 1 * sin(midRadians))
                    )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieSliceView_Previews: PreviewProvider {
    static var previews: some View {
        PieSliceView(pieSlice: PieSlice(startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 120), text: "4 Points", color: .yellow), glassLook: false)
            .frame(width: 250)
    }
}
