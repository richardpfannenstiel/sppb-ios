//
//  GaitDetailsView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 14.10.23.
//

import SwiftUI

struct GaitDetailsView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let gaitSpeedLabel = "Gait Speed".localized
        static let pointsLabel = "Points".localized
        static let averageSpeed = "Average Speed".localized
        static let showDetailsInstructions = "Tab on a diagram to show more details about the test result.".localized
    }
    
    // MARK: - Stored Properties
    
    let color: Color
    
    let firstGait: GaitTest
    let secondGait: GaitTest
    
    let printVersion: Bool
    
    @State var firstGaitTime: CGFloat = 0
    var firstGaitMaxTime: CGFloat {
        CGFloat(firstGait.maximumTime)
    }
    var firstGaitAverageSpeed: CGFloat {
        CGFloat(firstGait.distance) / firstGaitTime
    }
    var firstGaitBarPortion: CGFloat {
        tanh((CGFloat(firstGaitTime) / (firstGaitMaxTime / 4)))
    }
    
    @State var secondGaitTime: CGFloat = 0
    var secondGaitMaxTime: CGFloat {
        CGFloat(secondGait.maximumTime)
    }
    var secondGaitAverageSpeed: CGFloat {
        CGFloat(secondGait.distance) / secondGaitTime
    }
    var secondGaitBarPortion: CGFloat {
        tanh((CGFloat(secondGaitTime) / (secondGaitMaxTime / 4)))
    }
    
    var totalPoints: Int {
        Int(max(firstGait.result?.points ?? 0, secondGait.result?.points ?? 0))
    }
    
    var maxTotalPoints: Int {
        Int(max(firstGait.maximumPoints, secondGait.maximumPoints))
    }
    
    @State var selectedTest: GaitTest? = nil
    
    init(color: Color, firstGait: GaitTest, secondGait: GaitTest, printVersion: Bool = false) {
        self.color = color
        self.firstGait = firstGait
        self.secondGait = secondGait
        self.printVersion = printVersion
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Constant.gaitSpeedLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text("\(totalPoints)/\(maxTotalPoints) \(Constant.pointsLabel)")
                    .rounded(weight: .semibold)
            }
            
            VStack(spacing: 20) {
                VStack {
                    HStack {
                        Text("\(Constant.averageSpeed): \(String(format: "%.2f", firstGaitAverageSpeed))m/s")
                            .rounded()
                        Spacer()
                        Text("\(String(format: "%.2f", firstGaitTime))s")
                            .rounded()
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                                .frame(height: 25)
                            RoundedRectangle(cornerRadius: 30)
                                .fill(firstGaitTime < secondGaitTime ? color : .gray)
                                .frame(width: firstGaitBarPortion * geometry.size.width, height: 25)
                                .animation(.interpolatingSpring(stiffness: 50, damping: 8).speed(0.5), value: firstGaitBarPortion)
                        }
                    }.frame(height: 25)
                    
                    Text(firstGait.title)
                        .rounded(size: 12)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.onTapGesture(perform: { select(firstGait) })
                VStack {
                    HStack {
                        Text("\(Constant.averageSpeed): \(String(format: "%.2f", secondGaitAverageSpeed))m/s")
                            .rounded()
                        Spacer()
                        Text("\(String(format: "%.2f", secondGaitTime))s")
                            .rounded()
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                                .frame(height: 25)
                            RoundedRectangle(cornerRadius: 30)
                                .fill(secondGaitTime < firstGaitTime ? color : .gray)
                                .frame(width: secondGaitBarPortion * geometry.size.width, height: 25)
                                .animation(.interpolatingSpring(stiffness: 50, damping: 8).speed(0.5), value: secondGaitBarPortion)
                        }
                    }.frame(height: 25)
                    
                    Text(secondGait.title)
                        .rounded(size: 12)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.onTapGesture(perform: { select(secondGait) })
            }.padding(.vertical)
            
            if printVersion {
                summary
            } else {
                if let test = selectedTest, let result = test.result {
                    Text(test.title)
                        .rounded(weight: .semibold)
                    Text(result.comment.feedback(for: test))
                        .rounded()
                } else {
                    Text(Constant.showDetailsInstructions)
                        .rounded()
                }
            }
        }.onAppear(perform: animate)
    }
    
    private var summary: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text(firstGait.title)
                    .rounded(weight: .semibold)
                if let firstGaitResult = firstGait.result {
                    Text(firstGaitResult.comment.feedback(for: firstGait)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", firstGaitResult.time.rounded(.down)))"))
                        .rounded()
                }
            }
            
            VStack(alignment: .leading) {
                Text(secondGait.title)
                    .rounded(weight: .semibold)
                if let secondGaitResult = secondGait.result {
                    Text(secondGaitResult.comment.feedback(for: secondGait)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", secondGaitResult.time.rounded(.down)))"))
                        .rounded()
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func select(_ test: GaitTest) {
        withAnimation(.easeInOut) {
            selectedTest = test
        }
        FeedbackGenerator.haptic()
    }
    
    private func animate() {
        firstGaitTime = CGFloat(firstGait.result?.time ?? 0)
        secondGaitTime = CGFloat(secondGait.result?.time ?? 0)
    }
}

struct GaitDetailsView_Previews: PreviewProvider {
    static let firstGait = GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 6.87, points: 2, comment: .success, movementAbnormalities: []), number: 1)
    static let secondGait = GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 5.46, points: 3, comment: .success, movementAbnormalities: []), number: 2)
    
    static var previews: some View {
        GaitDetailsView(color: .blue, firstGait: firstGait, secondGait: secondGait)
            .padding(.horizontal, 50)
            .background(SimpleBackgroundView(backgroundColors: [.white, .cyan, .white]))
    }
}
