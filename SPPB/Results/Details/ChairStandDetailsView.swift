//
//  ChairStandDetailsView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 16.10.23.
//

import SwiftUI

struct ChairStandDetailsView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let chairStandLabel = "Chair Stand".localized
        static let pointsLabel = "Points".localized
        static let repetitions = "Repetitions".localized
        static let showDetailsInstructions = "Tab on a diagram to show more details about the test result.".localized
    }
    
    // MARK: - Stored Properties
    
    let color: Color
    
    let singleChairStand: ChairStandTest
    let repeatedChairStand: ChairStandTest
    
    let printVersion: Bool
    
    @State var singleChairStandTime: CGFloat = 0
    var singleChairStandMaxTime: CGFloat {
        CGFloat(singleChairStand.maximumTime)
    }
    var singleChairStandBarPortion: CGFloat {
        tanh((CGFloat(singleChairStandTime) / (singleChairStandMaxTime / 4)))
    }
    
    @State var repeatedChairStandTime: CGFloat = 0
    var repeatedChairStandMaxTime: CGFloat {
        CGFloat(repeatedChairStand.maximumTime)
    }
    var repeatedChairStandBarPortion: CGFloat {
        tanh((CGFloat(repeatedChairStandTime) / (repeatedChairStandMaxTime / 4)))
    }
    
    var totalPoints: Int {
        repeatedChairStand.result?.points ?? 0
    }
    
    var maxTotalPoints: Int {
        repeatedChairStand.maximumPoints
    }
    
    @State var selectedTest: ChairStandTest? = nil
    
    init(color: Color, singleChairStand: ChairStandTest, repeatedChairStand: ChairStandTest, printVersion: Bool = false) {
        self.color = color
        self.singleChairStand = singleChairStand
        self.repeatedChairStand = repeatedChairStand
        self.printVersion = printVersion
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Constant.chairStandLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text("\(totalPoints)/\(maxTotalPoints) \(Constant.pointsLabel)")
                    .rounded(weight: .semibold)
            }
            
            VStack(spacing: 20) {
                VStack {
                    HStack {
                        Text("\(singleChairStand.result?.comment.rawValue ?? "")")
                            .rounded()
                        Spacer()
                        Text(singleChairStandTime > 0 ? "\(String(format: "%.2f", singleChairStandTime))s" : "-")
                            .rounded()
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                                .frame(height: 25)
                            RoundedRectangle(cornerRadius: 30)
                                .fill(color)
                                .frame(width: singleChairStandBarPortion * geometry.size.width, height: 25)
                                .animation(.interpolatingSpring(stiffness: 50, damping: 8).speed(0.5), value: singleChairStandBarPortion)
                        }
                    }.frame(height: 25)
                    
                    Text(singleChairStand.title)
                        .rounded(size: 12)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.onTapGesture(perform: { select(singleChairStand) })
                
                VStack {
                    HStack {
                        Text("\(repeatedChairStand.repetitions) \(Constant.repetitions)")
                            .rounded()
                        Spacer()
                        Text(repeatedChairStandTime > 0 ? "\(String(format: "%.2f", repeatedChairStandTime))s" : "-")
                            .rounded()
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                                .frame(height: 25)
                            RoundedRectangle(cornerRadius: 30)
                                .fill(color)
                                .frame(width: repeatedChairStandBarPortion * geometry.size.width, height: 25)
                                .animation(.interpolatingSpring(stiffness: 50, damping: 8).speed(0.5), value: repeatedChairStandBarPortion)
                        }
                    }.frame(height: 25)
                    
                    Text(repeatedChairStand.title)
                        .rounded(size: 12)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.onTapGesture(perform: { select(repeatedChairStand) })
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
                Text(singleChairStand.title)
                    .rounded(weight: .semibold)
                if let singleChairStandResult = singleChairStand.result {
                    Text(singleChairStandResult.comment.feedback(for: singleChairStand)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", singleChairStandResult.time.rounded(.down)))"))
                        .rounded()
                }
            }
            
            VStack(alignment: .leading) {
                Text(repeatedChairStand.title)
                    .rounded(weight: .semibold)
                if let repeatedChairStandResult = repeatedChairStand.result {
                    Text(repeatedChairStandResult.comment.feedback(for: repeatedChairStand)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", repeatedChairStandResult.time.rounded(.down)))"))
                        .rounded()
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func select(_ test: ChairStandTest) {
        withAnimation(.easeInOut) {
            selectedTest = test
        }
        FeedbackGenerator.haptic()
    }
    
    private func animate() {
        singleChairStandTime = CGFloat(singleChairStand.result?.time ?? 0)
        repeatedChairStandTime = CGFloat(repeatedChairStand.result?.time ?? 0)
    }
}

struct ChairStandDetailsView_Previews: PreviewProvider {
    static let singleChairStand = ChairStandTest(title: "Single Chair Stand Test", instructions: "", result: Result(time: 1.45, points: 0, comment: .success, movementAbnormalities: []), testType: .single)
    static let repeatedChairStand = ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", result: Result(time: 12.5, points: 3, comment: .success, movementAbnormalities: []), testType: .repeated)
    
    static var previews: some View {
        ChairStandDetailsView(color: .blue, singleChairStand: singleChairStand, repeatedChairStand: repeatedChairStand)
            .padding(.horizontal, 50)
            .background(SimpleBackgroundView(backgroundColors: [.white, .cyan, .white]))
    }
}
