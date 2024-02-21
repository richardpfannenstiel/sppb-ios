//
//  MovementDetailsView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 17.11.23.
//

import SwiftUI

struct MovementDetailsView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let titleLabel = "Movement Details".localized
        static let descriptionText = "Detected conspicuities in the patient's movement".localized
        static let balanceLabel = "Balance".localized
        static let gaitSpeedLabel = "Gait Speed".localized
        static let chairStandLabel = "Chair Stand".localized
        
        static let chairStandNoAbnormalitiesLabel = "The patient performed the exercise as expected and kept his arms crossed in front of the chest during the exercise.".localized
    }
    
    // MARK: - Stored Properties
    
    @ObservedObject var model: ResultsViewModel
    let size: CGFloat = 1000
    
    // MARK: - Computed Properties
    
    var sideBySideAbnormalities: [String] {
        model.tests
            .filter({ ($0 as? BalanceTest)?.pose == .side_by_side })
            .flatMap({ $0.result?.movementAbnormalities ?? [] })
            .map({ $0.description })
    }
    
    var semiTandemAbnormalities: [String] {
        model.tests
            .filter({ ($0 as? BalanceTest)?.pose == .semi_tandem })
            .flatMap({ $0.result?.movementAbnormalities ?? [] })
            .map({ $0.description })
    }
    
    var tandemAbnormalities: [String] {
        model.tests
            .filter({ ($0 as? BalanceTest)?.pose == .tandem })
            .flatMap({ $0.result?.movementAbnormalities ?? [] })
            .map({ $0.description })
    }
    
    var gaitAbnormalities: [String] {
        model.tests
            .filter({ $0 is GaitTest })
            .flatMap({ $0.result?.movementAbnormalities ?? [] })
            .map({ $0.description })
    }
    
    var chairRiseAbnormalities: [String] {
        model.tests
            .filter({ $0 is ChairStandTest })
            .flatMap({ $0.result?.movementAbnormalities ?? [] })
            .map({ $0.description })
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(Constant.titleLabel)
                .rounded(size: 30, weight: .semibold)
            Text(Constant.descriptionText)
                .rounded(size: 25)
            
            Text(Constant.balanceLabel)
                .rounded(size: 25, weight: .semibold)
                .padding(.top, 50)
            balanceAbnormalitiesView
            
            Text(Constant.gaitSpeedLabel)
                .rounded(size: 25, weight: .semibold)
                .padding(.top, 50)
            gaitAbnormalitiesView
            
            Text(Constant.chairStandLabel)
                .rounded(size: 25, weight: .semibold)
                .padding(.top, 50)
            chairRiseAbnormalitiesView
        }.padding(.all, 50)
        .frame(width: size)
    }
    
    private var balanceAbnormalitiesView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(model.balanceTests[0].title)
                ForEach(sideBySideAbnormalities, id: \.self) { abnormality in
                    if !abnormality.isEmpty {
                        descriptionViewTile(for: abnormality, fixedHeight: 75)
                    }
                }
            }.frame(width: (size - 100) / 3)
            VStack(alignment: .leading) {
                Text(model.balanceTests[1].title)
                ForEach(semiTandemAbnormalities, id: \.self) { abnormality in
                    if !abnormality.isEmpty {
                        descriptionViewTile(for: abnormality, fixedHeight: 75)
                    }
                }
            }.frame(width: (size - 100) / 3)
            VStack(alignment: .leading) {
                Text(model.balanceTests[2].title)
                ForEach(tandemAbnormalities, id: \.self) { abnormality in
                    if !abnormality.isEmpty {
                        descriptionViewTile(for: abnormality, fixedHeight: 75)
                    }
                }
            }.frame(width: (size - 100) / 3)
        }
    }
    
    private var gaitAbnormalitiesView: some View {
        ForEach(gaitAbnormalities.uniqued(), id: \.self) { abnormality in
            if !abnormality.isEmpty {
                descriptionViewTile(for: abnormality)
            }
        }
    }
    
    private var chairRiseAbnormalitiesView: some View {
        VStack {
            if chairRiseAbnormalities.reduce("", +).isEmpty {
                descriptionViewTile(for: Constant.chairStandNoAbnormalitiesLabel)
            } else {
                ForEach(chairRiseAbnormalities.uniqued(), id: \.self) { abnormality in
                    if !abnormality.isEmpty {
                        descriptionViewTile(for: abnormality)
                    }
                }
            }
        }
    }
    
    private func descriptionViewTile(for text: String, fixedHeight: CGFloat? = nil) -> some View {
        HStack {
            Text(text)
                .rounded()
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }.frame(height: fixedHeight)
        .padding(.all, 10)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

struct MovementDetailsView_Previews: PreviewProvider {
    static let tests: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 10, points: 1, comment: .success, movementAbnormalities: [BalanceAbnormality.leftArmConstantlyBent(share: 0.9), BalanceAbnormality.rightArmConstantlyBent(share: 0.8), BalanceAbnormality.oneArmConstantlyBent(share: 0.9), BalanceAbnormality.armsUsedToKeepBalance(share: 0.0), BalanceAbnormality.wobbling(offset: 9)]), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 10, points: 1, comment: .success, movementAbnormalities: [BalanceAbnormality.leftArmConstantlyBent(share: 0.7), BalanceAbnormality.rightArmConstantlyBent(share: 0.0), BalanceAbnormality.oneArmConstantlyBent(share: 0.7), BalanceAbnormality.armsUsedToKeepBalance(share: 0.0), BalanceAbnormality.wobbling(offset: 28)]), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: [BalanceAbnormality.leftArmConstantlyBent(share: 0.5), BalanceAbnormality.rightArmConstantlyBent(share: 0.0), BalanceAbnormality.oneArmConstantlyBent(share: 0.5), BalanceAbnormality.armsUsedToKeepBalance(share: 0.0), BalanceAbnormality.wobbling(offset: 32)]), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 5.89, points: 3, comment: .success, movementAbnormalities: [GaitAbnormality.oneArmConstantlyBent(share: 0.7), .stepSize(max: 302), .faltering(offset: 125)]), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 10.67, points: 2, comment: .success, movementAbnormalities: [GaitAbnormality.oneArmConstantlyBent(share: 0.0), .stepSize(max: 302), .faltering(offset: 104)]), number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", result: Result(time: 2.56, points: 0, comment: .success, movementAbnormalities: [ChairRiseAbormality.armsNotFoldedAcrossChest(share: 0.0), .feetSpacedVerticallyApart(distance: 6)]), testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", result: Result(time: 12.5, points: 2, comment: .success, movementAbnormalities: [ChairRiseAbormality.armsNotFoldedAcrossChest(share: 0.8), .feetSpacedVerticallyApart(distance: 12)]), testType: .repeated)
    ]
    
    static let battery = Battery(assessmentType: .clinical, subject: "Jonas Stefano", instructor: "Lukas Kübbers", administrator: "Mara Leimer", date: Date(), location: .medicalFacility, tests: tests)
    
    static var previews: some View {
        MovementDetailsView(model: ResultsViewModel(for: battery))
    }
}
