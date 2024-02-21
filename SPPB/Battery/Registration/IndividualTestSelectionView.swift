//
//  IndividualTestSelectionView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 29.08.23.
//

import SwiftUI

// THIS STRUCT IS ONLY USED FOR DEBUG PURPOSES TO TEST INDIVIDUAL EVALUATIONS.

struct IndividualTestSelectionView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let balanceTestLabel = "Balance Tests".localized
        static let sideBySideLabel = "Side-by-Side Stand".localized
        static let semiTandemLabel = "Semi-Tandem Stand".localized
        static let tandemLabel = "Tandem Stand".localized
        static let gaitSpeedTestLabel = "Gait Speed Test".localized
        static let singleChairStandLabel = "Single Chair Stand Test".localized
        static let repeatedChairStandLabel = "Repeated Chair Stand Test".localized
        
        static let sideBySideTest = BalanceTest(title: "Side-by-Side Stand".localized, instructions: BalancePose.side_by_side.instructions, pose: .side_by_side)
        static let semiTandemTest = BalanceTest(title: "Semi-Tandem Stand".localized, instructions: BalancePose.semi_tandem.instructions, pose: .semi_tandem)
        static let tandemTest = BalanceTest(title: "Tandem Stand".localized, instructions: BalancePose.tandem.instructions, pose: .tandem)
        static let gaitSpeedTest = GaitTest(title: "Gait Speed Test".localized, instructions: GaitTest.firstWalkInstructions)
        static let singleChairStandTest = ChairStandTest(title: "Single Chair Stand Test".localized, instructions: ChairStandTestType.single.instructions, testType: .single)
        static let repeatedChairStandTest = ChairStandTest(title: "Repeated Chair Stand Test".localized, instructions: ChairStandTestType.repeated.instructions, testType: .repeated)
    }
    
    // MARK: - State
    
    @State var showingSideBySideTest = false
    @State var showingSemiTandemTest = false
    @State var showingTandemTest = false
    @State var showingGaitSpeedTest = false
    @State var showingSingleChairStandTest = false
    @State var showingRepeatedChairStandTest = false
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: { showingSideBySideTest.toggle() }) {
                Text(Constant.sideBySideLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton())
                .fullScreenCover(isPresented: $showingSideBySideTest) {
                    BalanceTestView(model: BalanceTestViewModel(forIndividual: Constant.sideBySideTest))
                        .colorScheme(.light)
                }
            Button(action: { showingSemiTandemTest.toggle() }) {
                Text(Constant.semiTandemLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton())
                .fullScreenCover(isPresented: $showingSemiTandemTest) {
                    BalanceTestView(model: BalanceTestViewModel(forIndividual: Constant.semiTandemTest))
                        .colorScheme(.light)
                }
            Button(action: { showingTandemTest.toggle() }) {
                Text(Constant.tandemLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton())
                .fullScreenCover(isPresented: $showingTandemTest) {
                    BalanceTestView(model: BalanceTestViewModel(forIndividual: Constant.tandemTest))
                        .colorScheme(.light)
                }
            Spacer()
            Button(action: { showingGaitSpeedTest.toggle() }) {
                Text(Constant.gaitSpeedTestLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton())
                .fullScreenCover(isPresented: $showingGaitSpeedTest) {
                    GaitTestView(model: GaitTestViewModel(forIndividual: Constant.gaitSpeedTest))
                        .colorScheme(.light)
                }
            Spacer()
            Button(action: { showingSingleChairStandTest.toggle() }) {
                Text(Constant.singleChairStandLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton())
                .fullScreenCover(isPresented: $showingSingleChairStandTest) {
                    ChairStandTestView(model: ChairStandTestViewModel(forIndividual: Constant.singleChairStandTest))
                        .colorScheme(.light)
                }
            Button(action: { showingRepeatedChairStandTest.toggle() }) {
                Text(Constant.repeatedChairStandLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton())
                .fullScreenCover(isPresented: $showingRepeatedChairStandTest) {
                    ChairStandTestView(model: ChairStandTestViewModel(forIndividual: Constant.repeatedChairStandTest))
                        .colorScheme(.light)
                }
            Spacer()
        }
    }
}

struct IndividualTestSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        IndividualTestSelectionView()
    }
}
