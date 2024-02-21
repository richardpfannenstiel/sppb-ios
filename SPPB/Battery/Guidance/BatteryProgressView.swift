//
//  BatteryProgressView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 03.07.23.
//

import SwiftUI

struct BatteryProgressView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let continueButtonLabel = "Continue".localized
    }
    
    @StateObject var model: BatteryProgressModel
    @Namespace var animation
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                if model.showingBalanceTestsHighlighted {
                    ProgressBalanceView(model: model, namespace: animation)
                } else {
                    if model.showingGaitTestsHighlighted {
                        ProgressGaitView(model: model, namespace: animation)
                    } else {
                        if model.showingChairStandTestsHighlighted {
                            ProgressChairStandView(model: model, namespace: animation)
                        } else {
                            ProgressOverView(model: model, namespace: animation)
                        }
                    }
                }
                Spacer()
            }.frame(width: width - 50, height: height * (3/4))
                .background(.ultraThinMaterial)
                .cornerRadius(15)
            Spacer()
            Button(action: model.next) {
                Text(Constant.continueButtonLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton(tint: model.animationFinished ? .blue : .gray))
                .disabled(!model.animationFinished)
        }.background(BackgroundView())
            .onAppear(perform: model.setup)
    }
}

struct BatteryProgressView_Previews: PreviewProvider {
    static let finished: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), testType: .repeated)
    ]
    
    static let singleChairFailed: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), testType: .repeated)
    ]
    
    static let singleChairFinished: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let gaitFinished: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let firstGaitFailed: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let firstGaitFinished: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let balanceFinished: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let semiTandemFailed: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "",  result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let semiTandemFinished: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let sideBySideFailed: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 0, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let sideBySideCompleted: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 0, points: 1, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static let started: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", testType: .repeated)
    ]
    
    static var previews: some View {
        BatteryProgressModel.lastTestsStatus = firstGaitFailed
        return BatteryProgressView(model: BatteryProgressModel(for: singleChairFailed))
    }
}
