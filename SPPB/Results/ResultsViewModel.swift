//
//  ResultsViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.10.23.
//

import SwiftUI
import PDFKit

final class ResultsViewModel: ViewModel {
    
    // MARK: - Stored Properties
    
    let tests: [Test]
    let assessmentType: AssessmentType
    let date: Date
    let subject: String
    let instructor: String
    let administrator: String
    let location: Location
    
    let restrictionPredictor: RestrictionPredictor
    
    let reset: () -> ()
    
    @Published var selectedDetails: Int? = nil
    @Published var pdf: URL? = nil
    @Published var csv: URL? = nil
    
    @Published var showingResetAlert = false
    
    // MARK: - Computed Properties
    
    var balanceTests: [BalanceTest] {
        tests.compactMap({ $0 as? BalanceTest })
    }
    
    var balancePoints: Int {
        totalPoints(in: balanceTests)
    }
    
    var gaitTests: [GaitTest] {
        tests.compactMap({ $0 as? GaitTest })
    }
    
    var gaitPoints: Int {
        maxPoints(in: gaitTests)
    }
    
    var chairStandTests: [ChairStandTest] {
        tests.compactMap({ $0 as? ChairStandTest })
    }
    
    var chairStandPoints: Int {
        totalPoints(in: chairStandTests)
    }
    
    let balanceColor = Color(hex: 0x03396c)
    let gaitSpeedColor = Color(hex: 0x005b96)
    let chairStandColor = Color(hex: 0x6497b1)
    
    var selectedColor: Color {
        switch selectedDetails {
        case .none:
                return .cyan
        case .some(let value):
            switch value {
            case 0: return balanceColor
                case 1: return gaitSpeedColor
                case 2: return chairStandColor
            default: return .cyan
            }
        }
    }
    
    var movementAbnormalities: [MovementAbnormality] {
        tests.flatMap({ $0.result?.movementAbnormalities ?? [] })
    }
    
    // MARK: - Initializer
    
    init(for battery: Battery) {
        guard let assessmentType = battery.assessmentType, let date = battery.date, let subject = battery.subject, let instructor = battery.instructor, let administrator = battery.administrator, let location = battery.location else {
            fatalError("Environment not set.")
        }
        self.assessmentType = assessmentType
        self.date = date
        self.subject = subject
        self.instructor = instructor
        self.administrator = administrator
        self.location = location
        self.reset = battery.reset
        self.tests = battery.tests
        
        self.restrictionPredictor = RestrictionPredictor()
        
        Task { @MainActor in
            pdf = renderPDF()
            csv = renderCSV()
        }
    }
    
    // MARK: - Private Functions
    
    private func totalPoints(in tests: [Test]) -> Int {
        tests.reduce(0, { $0 + ($1.result?.points ?? 0) })
    }
    
    private func maxPoints(in tests: [Test]) -> Int {
        tests.max(by: { ($0.result?.points ?? 0) < ($1.result?.points ?? 0) })?.result?.points ?? 0
    }
    
    @MainActor
    private func renderPDF() -> URL {
        let summaryPDF = PDFDocument(from: SummaryView(model: self))
        let abnormalitiesPDF = PDFDocument(from: MovementDetailsView(model: self))
        
        guard let summaryPDF = summaryPDF, let abnormalitiesPDF = abnormalitiesPDF else {
            fatalError("Could not generate PDFs.")
        }
        
        let fileName = "SPPB_\(subject)_\(date.formatted(date: .numeric, time: .omitted)).pdf"
        let url = URL.documentsDirectory.appending(path: fileName)
        
        guard let pdf = PDFDocument(mergedFrom: [summaryPDF, abnormalitiesPDF]) else {
            fatalError("Could not merge PDFs.")
        }
        
        pdf.write(to: url)
        return url
    }
    
    private func renderCSV() -> URL {
        let fileName = "SPPB_\(subject)_\(date.formatted(date: .numeric, time: .omitted)).csv"
        let url = URL.documentsDirectory.appending(path: fileName)
        
        // Define file columns.
        let identificationColumns = "subject,instructor,administrator,date,location,"
        let balanceTestColumns = "duration_side_by_side,duration_semi_tandem,duration_tandem,score_balance,"
        let gaitTestColumns = "duration_first_gait,duration_second_gait,score_gait,"
        let chairStandTestColumns = "duration_single_chairStand,duration_repeated_chairStand,score_chairStand,"
        let finalScoreColumns = "score_total,"
        let restrictionScoreColumns = "healthy_presumption,hemiplegia_presumption,parkinson_presumption,frailty_presumption,predicted_restriction\n"
        
        let columnString = [identificationColumns, balanceTestColumns, gaitTestColumns, chairStandTestColumns, finalScoreColumns, restrictionScoreColumns].reduce("", +)
        
        // Write file values.
        let identificationValues = "\(subject),\(instructor),\(administrator),\(date.formatted(date: .numeric, time: .omitted)),\(location),"
        let balanceTestValues = "\(balanceTests[0].result?.time ?? 0),\(balanceTests[1].result?.time ?? 0),\(balanceTests[2].result?.time ?? 0),\(balancePoints),"
        let gaitTestValues = "\((gaitTests[0].result?.time ?? 0)),\((gaitTests[1].result?.time ?? 0)),\(gaitPoints),"
        let chairStandTestValues = "\(chairStandTests[0].result?.time ?? 0),\(chairStandTests[1].result?.time ?? 0),\(chairStandPoints),"
        let totalScoreValues = "\([balancePoints, gaitPoints, chairStandPoints].reduce(0, +)),"
        
        let predictionResult = restrictionPredictor.predict(basedOn: movementAbnormalities)
        let restrictionScoreValues = "\(predictionResult[nil] ?? 0),\(predictionResult[.hemiplegia] ?? 0),\(predictionResult[.parkinson] ?? 0),\(predictionResult[.frailty] ?? 0),\(predictionResult.max(by: { $0.value < $1.value })!.key?.rawValue ?? "healthy")\n"
        
        let valueString = [identificationValues, balanceTestValues, gaitTestValues, chairStandTestValues, totalScoreValues,restrictionScoreValues].reduce("", +)
        
        do {
            let output = columnString + valueString
            try output.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Could not create CSV file.")
        }
        return url
    }
    
    private func share(url: URL, fromView view: some View) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let thisViewVC = UIHostingController(rootView: view)
            activityVC.popoverPresentationController?.sourceView = thisViewVC.view
        }
        
        UIApplication.shared.connectedScenes.flatMap {($0 as? UIWindowScene)?.windows ?? []}.first {$0.isKeyWindow}?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - Functions
    
    func initiateReset() {
        showingResetAlert = true
    }
    
    func sharePDF(fromView view: some View) {
        if let pdf = pdf {
            share(url: pdf, fromView: view)
        }
    }
    
    func shareCSV(fromView view: some View) {
        if let csv = csv {
            share(url: csv, fromView: view)
        }
    }
}
