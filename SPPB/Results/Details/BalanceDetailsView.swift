//
//  BalanceDetailsView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.10.23.
//

import SwiftUI

struct BalanceDetailsView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let balanceLabel = "Balance".localized
        static let pointsLabel = "Points".localized
        static let showDetailsInstructions = "Tab on a diagram to show more details about the test result.".localized
    }
    
    // MARK: - Stored Properties
    
    let color: Color
    
    let sideBySideTest: BalanceTest
    let semiTandemTest: BalanceTest
    let tandemTest: BalanceTest
    
    let printVersion: Bool
    
    @State var sideBySideTime: CGFloat = 0
    var sideBySideMaxTime: CGFloat {
        CGFloat(sideBySideTest.maximumTime)
    }
    var sideBySideBarHeight: CGFloat {
        (sideBySideTime / sideBySideMaxTime) * 100
    }
    
    @State var semiTandemTime: CGFloat = 0
    var semiTandemMaxTime: CGFloat {
        CGFloat(semiTandemTest.maximumTime)
    }
    var semiTandemBarHeight: CGFloat {
        (semiTandemTime / semiTandemMaxTime) * 100
    }
    
    @State var tandemTime: CGFloat = 0
    var tandemMaxTime: CGFloat {
        CGFloat(tandemTest.maximumTime)
    }
    var tandemBarHeight: CGFloat {
        (tandemTime / tandemMaxTime) * 100
    }
    
    var totalPoints: Int {
        (sideBySideTest.result?.points ?? 0) +
        (semiTandemTest.result?.points ?? 0) +
        (tandemTest.result?.points ?? 0)
    }
    
    var maxTotalPoints: Int {
        sideBySideTest.maximumPoints +
        semiTandemTest.maximumPoints +
        tandemTest.maximumPoints
    }
    
    @State var selectedTest: BalanceTest? = nil
    
    init(color: Color, sideBySideTest: BalanceTest, semiTandemTest: BalanceTest, tandemTest: BalanceTest, printVersion: Bool = false) {
        self.color = color
        self.sideBySideTest = sideBySideTest
        self.semiTandemTest = semiTandemTest
        self.tandemTest = tandemTest
        self.printVersion = printVersion
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Constant.balanceLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text("\(totalPoints)/\(maxTotalPoints) \(Constant.pointsLabel)")
                    .rounded(weight: .semibold)
            }
            
            HStack(alignment: .top) {
                VStack {
                    Text(sideBySideTime > 0 ? "\(String(format: "%.2f", sideBySideTime))s" : "-")
                        .rounded()
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .frame(width: 25, height: 100)
                        RoundedRectangle(cornerRadius: 30)
                            .fill(color)
                            .frame(width: 25, height: sideBySideBarHeight)
                            .animation(.interpolatingSpring(stiffness: 50, damping: 8).speed(0.5), value: sideBySideBarHeight)
                    }
                    Divider()
                        .opacity(0)
                    Text(sideBySideTest.title)
                        .rounded(size: 12)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.onTapGesture(perform: { select(sideBySideTest) })
                Spacer()
                VStack {
                    Text(semiTandemTime > 0 ? "\(String(format: "%.2f", semiTandemTime))s" : "-")
                        .rounded()
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .frame(width: 25, height: 100)
                        RoundedRectangle(cornerRadius: 30)
                            .fill(color)
                            .frame(width: 25, height: semiTandemBarHeight)
                            .animation(.interpolatingSpring(stiffness: 50, damping: 8).speed(0.5), value: semiTandemBarHeight)
                    }
                    Divider()
                        .opacity(0)
                    Text(semiTandemTest.title)
                        .rounded(size: 12)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.onTapGesture(perform: { select(semiTandemTest) })
                Spacer()
                VStack {
                    Text(tandemTime > 0 ? "\(String(format: "%.2f", tandemTime))s" : "-")
                        .rounded()
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .frame(width: 25, height: 100)
                        RoundedRectangle(cornerRadius: 30)
                            .fill(color)
                            .frame(width: 25, height: tandemBarHeight)
                            .animation(.interpolatingSpring(stiffness: 50, damping: 8).speed(0.5), value: tandemBarHeight)
                    }
                    Divider()
                        .opacity(0)
                    Text(tandemTest.title)
                        .rounded(size: 12)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.onTapGesture(perform: { select(tandemTest) })
            }.padding(.vertical)
            
            if printVersion {
                summary
            } else {
                if let test = selectedTest, let result = test.result {
                    Text(test.title)
                        .rounded(weight: .semibold)
                    Text(result.comment.feedback(for: test)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", result.time.rounded(.down)))"))
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
                Text(sideBySideTest.title)
                    .rounded(weight: .semibold)
                if let sideBySideResult = sideBySideTest.result {
                    Text(sideBySideResult.comment.feedback(for: sideBySideTest)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", sideBySideResult.time.rounded(.down)))"))
                        .rounded()
                }
            }
            
            VStack(alignment: .leading) {
                Text(semiTandemTest.title)
                    .rounded(weight: .semibold)
                if let semiTandemTestResult = semiTandemTest.result {
                    Text(semiTandemTestResult.comment.feedback(for: semiTandemTest)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", semiTandemTestResult.time.rounded(.down)))"))
                        .rounded()
                }
            }
            
            VStack(alignment: .leading) {
                Text(tandemTest.title)
                    .rounded(weight: .semibold)
                if let tandemTestResult = tandemTest.result {
                    Text(tandemTestResult.comment.feedback(for: tandemTest)
                        .replacingOccurrences(of: "$time", with: "\(String(format: "%.0f", tandemTestResult.time.rounded(.down)))"))
                        .rounded()
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func select(_ test: BalanceTest) {
        withAnimation(.easeInOut) {
            selectedTest = test
        }
        FeedbackGenerator.haptic()
    }
    
    private func animate() {
        sideBySideTime = CGFloat(sideBySideTest.result?.time ?? 0)
        semiTandemTime = CGFloat(semiTandemTest.result?.time ?? 0)
        tandemTime = CGFloat(tandemTest.result?.time ?? 0)
    }
}

struct BalanceDetailsView_Previews: PreviewProvider {
    static let sideBySideTest = BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 10, points: 1, comment: .success, movementAbnormalities: []), pose: .side_by_side)
    static let semiTandemTest = BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 8.78, points: 0, comment: .movementDetected, movementAbnormalities: []), pose: .semi_tandem)
    static let tandemTest = BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 4.99, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem)
    
    static var previews: some View {
        BalanceDetailsView(color: .blue, sideBySideTest: sideBySideTest, semiTandemTest: semiTandemTest, tandemTest: tandemTest)
            .padding(.horizontal, 50)
            .background(SimpleBackgroundView(backgroundColors: [.white, .cyan, .white]))
    }
}
