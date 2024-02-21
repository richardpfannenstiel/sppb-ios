//
//  TestBattery.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 28.06.23.
//

import SwiftUI

class Battery: ObservableObject {
    
    static let SPPB: [Test] = [
        BalanceTest(title: "Side-by-Side Stand".localized, instructions: BalancePose.side_by_side.instructions, pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand".localized, instructions: BalancePose.semi_tandem.instructions, pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand".localized, instructions: BalancePose.tandem.instructions, pose: .tandem),
        GaitTest(title: "First Gait Speed Test".localized, instructions: GaitTest.firstWalkInstructions),
        GaitTest(title: "Second Gait Speed Test".localized, instructions: GaitTest.subsequentWalkInstructions),
        ChairStandTest(title: "Single Chair Stand Test".localized, instructions: ChairStandTestType.single.instructions, testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test".localized, instructions: ChairStandTestType.repeated.instructions, testType: .repeated)
    ]
    
    static let SPPB_GaitSpeed: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: BalancePose.side_by_side.instructions, result: Result(time: 4.78, points: 0, comment: .movementDetected, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: BalancePose.semi_tandem.instructions, result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: BalancePose.tandem.instructions, result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: GaitTest.firstWalkInstructions),
        GaitTest(title: "Second Gait Speed Test", instructions: GaitTest.subsequentWalkInstructions),
        ChairStandTest(title: "Single Chair Stand Test", instructions: ChairStandTestType.single.instructions, testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: ChairStandTestType.repeated.instructions, testType: .repeated)
    ]
    
    static let SPPB_ChairStand: [Test] = [
        BalanceTest(title: "Side-by-Side Stand", instructions: BalancePose.side_by_side.instructions, result: Result(time: 4.78, points: 0, comment: .movementDetected, movementAbnormalities: []), pose: .side_by_side),
        BalanceTest(title: "Semi-Tandem Stand", instructions: BalancePose.semi_tandem.instructions, result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .semi_tandem),
        BalanceTest(title: "Tandem Stand", instructions: BalancePose.tandem.instructions, result: Result(time: 0, points: 0, comment: .skipped, movementAbnormalities: []), pose: .tandem),
        GaitTest(title: "First Gait Speed Test", instructions: GaitTest.firstWalkInstructions, result: Result(time: 2.54, points: 4, comment: .success, movementAbnormalities: [])),
        GaitTest(title: "Second Gait Speed Test", instructions: GaitTest.subsequentWalkInstructions, result: Result(time: 3.42, points: 4, comment: .success, movementAbnormalities: [])),
        ChairStandTest(title: "Single Chair Stand Test", instructions: ChairStandTestType.single.instructions, testType: .single),
        ChairStandTest(title: "Repeated Chair Stand Test", instructions: ChairStandTestType.repeated.instructions, testType: .repeated)
    ]
    
    // MARK: - Stored Properties
    
    @AppStorage("settings.disableSkippingTests") var disableSkippingTests = false
    
    @Published var assessmentType: AssessmentType?
    @Published var subject: String?
    @Published var instructor: String?
    @Published var administrator: String?
    @Published var location: Location?
    @Published var date: Date?
    
    @Published var showingIntroduction = true
    @Published var showingProgress = true
    
    @Published var tests: [Test]
    
    // MARK: - Computed Properties
    
    var isEnvironmentSet: Bool {
        assessmentType != nil &&
        subject != nil &&
        instructor != nil &&
        administrator != nil &&
        location != nil &&
        date != nil
    }
    
    var nextTest: Test? {
        tests.first(where: { !$0.isFinished })
    }
    
    var lastTest: Test? {
        tests.last(where: { $0.isFinished })
    }
    
    // MARK: - Initializer
    
    init(tests: [Test] = Battery.SPPB) {
        self.tests = tests
    }
    
    init(assessmentType: AssessmentType, subject: String, instructor: String, administrator: String, date: Date, location: Location, tests: [Test]) {
        self.assessmentType = assessmentType
        self.subject = subject
        self.instructor = instructor
        self.administrator = administrator
        self.date = date
        self.location = location
        self.tests = tests
    }
    
    // MARK: - Functions
    
    func setEnvironment(assessmentType: AssessmentType, subject: String, instructor: String, administrator: String, date: Date, location: Location) {
        self.assessmentType = assessmentType
        self.subject = subject
        self.instructor = instructor
        self.administrator = administrator
        self.date = date
        self.location = location
    }
    
    func start() {
        showingIntroduction = false
    }
    
    func next() {
        withAnimation(.default) {
            showingProgress = false
        }
    }
    
    func update(for test: Test) {
        // Update the test that was completed.
        save(test)
        
        // If the patient scored zero points for the test, check if subsequent tests should be skipped.
        // In case the option to avoid skipping of tests is enabled, proceed with the next test.
        if test.wasFailed && !disableSkippingTests {
            if test is BalanceTest {
                // A balance test failed, if subsequent balance tests are planned, those must be skipped.
                tests.filter({ $0 is BalanceTest && !$0.isFinished })
                    .forEach {
                        var balanceTest = $0
                        balanceTest.skip()
                        save(balanceTest)
                    }
            }
            if test is GaitTest {
                // A gait test failed, if it was the first of the two, the second test must be skipped.
                tests.filter({ $0 is GaitTest && !$0.isFinished })
                    .forEach {
                        var gaitTest = $0
                        gaitTest.skip()
                        save(gaitTest)
                    }
            }
            if test is ChairStandTest {
                // A chair stand test failed, if it was the single chair stand, the repeated exercise must be skipped.
                tests.filter({ $0 is ChairStandTest && !$0.isFinished })
                    .forEach {
                        var chairStandTest = $0
                        chairStandTest.skip()
                        save(chairStandTest)
                    }
            }
        }
        
        showingProgress = true
    }
    
    func save(_ test: Test) {
        if let index = tests.firstIndex(where: {$0.id == test.id}) {
            tests[index] = test
        }
    }
    
    func reset() {
        // Reset test environment.
        self.assessmentType = nil
        self.subject = nil
        self.instructor = nil
        self.administrator = nil
        self.date = nil
        self.location = nil
        
        // Go back to the introduction view and subsequently, the progress view.
        showingIntroduction = true
        showingProgress = true
        
        // Erase any test results and start a new SPPB series.
        tests = Battery.SPPB
    }
}
