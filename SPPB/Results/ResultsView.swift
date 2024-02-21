//
//  ResultsView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 12.10.23.
//

import SwiftUI

struct ResultsView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let resultsTitle = "Battery Results".localized
        static let showDetailsInstructions = "Tab on the individual parts of the diagram to show details.".localized
        static let balanceLabel = "Balance".localized
        static let gaitSpeedLabel = "Gait Speed".localized
        static let chairStandLabel = "Chair Stand".localized
        static let exportLabel = "Export".localized
        static let exportAsPDFLabel = "As PDF document".localized
        static let exportASCSVLabel = "As CSV file".localized
        static let resetLabel = "Reset".localized
        
        static let alertLabel = "Warning".localized
        static let alertDescription = "Are you sure you want to reset the battery?\n\nThis will permanently erase the obtained test results in the application. Make sure you've exported and saved any data beforehand.".localized
    }
    
    // MARK: - Stored Properties
    
    @StateObject var model: ResultsViewModel
    
    var body: some View {
        VStack {
            PieChartView(selection: $model.selectedDetails, values: [
                model.balancePoints, model.gaitPoints, model.chairStandPoints
            ], names: [
                Constant.balanceLabel, Constant.gaitSpeedLabel, Constant.chairStandLabel
            ], colors: [model.balanceColor, model.gaitSpeedColor, model.chairStandColor])
            .frame(width: width / 1.6, height: width / 1.6)
                .padding(.top, 30)
                .padding(.bottom, 40)
            ZStack {
                switch model.selectedDetails {
                case .none:
                    batteryResults
                case .some(let value):
                    switch value {
                    case 0: BalanceDetailsView(color: model.selectedColor, sideBySideTest: model.balanceTests[0], semiTandemTest: model.balanceTests[1], tandemTest: model.balanceTests[2])
                    case 1: GaitDetailsView(color: model.selectedColor, firstGait: model.gaitTests[0], secondGait: model.gaitTests[1])
                    case 2: ChairStandDetailsView(color: model.selectedColor, singleChairStand: model.chairStandTests[0], repeatedChairStand: model.chairStandTests[1])
                        default: Text("")
                    }
                }
            }.padding()
                .frame(width: width - 50)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .animation(.default, value: model.selectedDetails)
            Spacer()
            actionButtons
            
        }.background(SimpleBackgroundView(backgroundColors: [.white, .cyan, .white]))
            .alert(Text(Constant.alertLabel), isPresented: $model.showingResetAlert, actions: {
                Button(Constant.resetLabel, role: .destructive, action: model.reset)
                }, message: {
                    Text(Constant.alertDescription)
                        .rounded()
                })
    }
    
    private var batteryResults: some View {
        VStack {
            Text(Constant.resultsTitle)
                .rounded(size: 30, weight: .semibold)
            Text(Constant.showDetailsInstructions)
                .rounded()
                .multilineTextAlignment(.center)
            BatteryEnvironmentListView(assessmentType: model.assessmentType, date: model.date, subject: model.subject, instructor: model.instructor, administrator: model.administrator, location: model.location)
                .padding(.top)
        }
    }
    
    private var actionButtons: some View {
        HStack(alignment: .bottom, spacing: 20) {
            exportButton
            resetButton
        }.frame(width: width - 50)
    }
    
    private var exportButton: some View {
        Button(action: { model.sharePDF(fromView: self) }) {
            HStack {
                Spacer()
                Text(Constant.exportLabel)
                    .rounded()
                Spacer()
            }
        }.buttonStyle(FlatGlassButton(tint: .blue))
            .contextMenu {
                Button(action: { model.sharePDF(fromView: self) }) {
                    HStack {
                        Text(Constant.exportAsPDFLabel)
                            .rounded()
                        Spacer()
                        Image(systemName: "doc.text.image")
                    }
                }
                Button(action: { model.shareCSV(fromView: self) }) {
                    HStack {
                        Text(Constant.exportASCSVLabel)
                            .rounded()
                        Spacer()
                        Image(systemName: "filemenu.and.selection")
                    }
                }
            }
    }
    
    private var resetButton: some View {
        Button(action: model.initiateReset) {
            HStack {
                Spacer()
                Text(Constant.resetLabel)
                    .rounded()
                Spacer()
            }
        }.buttonStyle(FlatGlassButton(tint: .red))
    }
}

struct ResultsView_Previews: PreviewProvider {
    
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
        ResultsView(model: ResultsViewModel(for: battery))
    }
}
