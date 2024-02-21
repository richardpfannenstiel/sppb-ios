//
//  TesfsefView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 17.10.23.
//

import SwiftUI

struct SummaryView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let titleLabel = "Short Physical Performance Battery".localized
        static let descriptionLabel = "Test Results".localized
        static let balanceLabel = "Balance".localized
        static let gaitSpeedLabel = "Gait Speed".localized
        static let chairStandLabel = "Chair Stand".localized
    }
    
    // MARK: - Stored Properties
    
    @ObservedObject var model: ResultsViewModel
    let size: CGFloat = 1000
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(Constant.titleLabel)
                .rounded(size: 30, weight: .semibold)
            Text(Constant.descriptionLabel)
                .rounded(size: 25)
            HStack {
                BatteryEnvironmentListView(assessmentType: model.assessmentType, date: model.date, subject: model.subject, instructor: model.instructor, administrator: model.administrator, location: model.location)
                    .frame(width: size / 2.5)
                Spacer()
                PieChartView(selection: $model.selectedDetails, values: [
                    model.balancePoints, model.gaitPoints, model.chairStandPoints
                ], names: [
                    Constant.balanceLabel, Constant.gaitSpeedLabel, Constant.chairStandLabel
                ], colors: [model.balanceColor, model.gaitSpeedColor, model.chairStandColor], glassLook: false)
                .frame(width: size / 2.5, height: size / 2.5)
            }.padding(.bottom, 75)
            HStack(alignment: .top) {
                BalanceDetailsView(color: model.selectedColor, sideBySideTest: model.balanceTests[0], semiTandemTest: model.balanceTests[1], tandemTest: model.balanceTests[2], printVersion: true)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(15)
                GaitDetailsView(color: model.selectedColor, firstGait: model.gaitTests[0], secondGait: model.gaitTests[1], printVersion: true)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(15)
                ChairStandDetailsView(color: model.selectedColor, singleChairStand: model.chairStandTests[0], repeatedChairStand: model.chairStandTests[1], printVersion: true)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(15)
            }
        }.padding(.all, 50)
        .frame(width: size)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static let tests: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: "", result: Result(time: 10, points: 1, comment: .success, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: "", result: Result(time: 10, points: 1, comment: .success, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: "", result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: "", result: Result(time: 5.89, points: 3, comment: .success, movementAbnormalities: []), number: 1),
        GaitTest(title: "Second Gait Speed Test", instructions: "", result: Result(time: 10.67, points: 2, comment: .success, movementAbnormalities: []), number: 2),
        ChairStandTest(title: "Single Chair Stand Test", instructions: "", result: Result(time: 2.56, points: 0, comment: .success, movementAbnormalities: []), testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: "", result: Result(time: 12.5, points: 2, comment: .success, movementAbnormalities: []), testType: .repeated)
    ]
    
    static let battery = Battery(assessmentType: .clinical, subject: "Jonas Stefano", instructor: "Lukas Kübbers", administrator: "Mara Leimer", date: Date(), location: .medicalFacility, tests: tests)
    
    static var previews: some View {
        SummaryView(model: ResultsViewModel(for: battery))
    }
}
