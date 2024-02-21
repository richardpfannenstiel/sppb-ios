//
//  PieChartView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 12.10.23.
//
//  The structure defined in this file has mainly been copied from Nazar Ilamanov provided in the following Medium article.
//  https://betterprogramming.pub/build-pie-charts-in-swiftui-822651fbf3f2
//

import SwiftUI

struct PieChartView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let totalText = "Total".localized
        static let pointsText = "Points".localized
    }
    
    // MARK: - Stored Properties
    
    let values: [Int]
    let names: [String]
    let colors: [Color]
    let innerRadiusFraction: CGFloat
    
    let glassLook: Bool
    
    @Binding var selectedSlice: Int?
    
    // MARK: - Computed Properties
    
    var total: Int {
        values.reduce(0, +)
    }
    
    var slices: [PieSlice] {
        var endDeg: Double = 0
        var slices: [PieSlice] = []
        
        for (i, value) in values.enumerated() {
            var degrees: Double
            if total > 0 {
                // The total is not zero, it's safe to divide by it.
                degrees = Double(value) * 360 / Double(total)
                
                if degrees > 0 {
                    let nonZeroValuesCount = values.filter({ $0 > 0 }).count
                    let deduction = Double(40 / nonZeroValuesCount)
                    degrees -= values.reduce(0, { $0 + ($1 > 0 ? 0 : deduction)})
                } else {
                    degrees = 40
                }
            } else {
                // All values are zero, distribute evenly.
                degrees = Double(360 / values.count)
            }
            
            var color = colors[i]
            if let selection = selectedSlice, selection != i {
                color = color.opacity(0.5)
            }
            
            slices.append(PieSlice(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: names[i], color: color))
            endDeg += degrees
        }
        return slices
    }
    
    // MARK: - Initializer
    
    init(selection: Binding<Int?>, values: [Int], names: [String], colors: [Color] = [.yellow, .blue, .red], innerRadiusFraction: CGFloat = 0.5, glassLook: Bool = true){
        _selectedSlice = selection
        self.values = values
        self.names = names
        self.colors = colors
        self.innerRadiusFraction = innerRadiusFraction
        self.glassLook = glassLook
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<values.count, id: \.self) { i in
                    PieSliceView(pieSlice: slices[i], glassLook: glassLook)
                        .scaleEffect(selectedSlice == i ? 1.1 : 1)
                        .animation(.interpolatingSpring(stiffness: 150, damping: 8), value: selectedSlice)
                        .onTapGesture(perform: { select(sliceNumber: i) })
                }.reverseMask {
                    Circle()
                        .frame(width: geometry.size.width * innerRadiusFraction)
                }
                VStack {
                    if let index = selectedSlice {
                        Text(Constant.pointsText)
                            .rounded(size: 22)
                        Text("\(values[index])")
                            .rounded(size: 30, weight: .semibold)
                    } else {
                        Text(Constant.totalText)
                            .rounded(size: 22)
                        Text("\(total)")
                            .rounded(size: 30, weight: .semibold)
                    }
                }.onTapGesture(perform: dismiss)
            }
        }
    }
    
    // MARK: - Functions
    
    private func select(sliceNumber: Int) {
        selectedSlice = sliceNumber
        FeedbackGenerator.haptic()
    }
    
    private func dismiss() {
        selectedSlice = nil
        FeedbackGenerator.haptic()
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(selection: .constant(nil), values: [4, 3, 4], names: ["Balance", "Gait Speed", "Chair Stand"])
            .padding(.all, 50)
    }
}
