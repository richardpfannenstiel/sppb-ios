//
//  RegistrationModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import SwiftUI

final class RegistrationModel: ViewModel {
    
    // MARK: - Stored Properties
    
    @Published var date = Date()
    @Published var subject = ""
    @Published var instructor = ""
    @Published var administrator = ""
    @Published var location: Location?
    
    @Published var assessmentType: AssessmentType?
    @Published var animationOffset: CGFloat = 200
    
    let createFunction: (AssessmentType, String, String, String, Date, Location) -> ()
    
    // MARK: - Computed Properties
    
    var buttonDisabled: Bool {
        subject.isEmpty || instructor.isEmpty || administrator.isEmpty || location == nil
    }
    
    // MARK: - Initializer
    
    init(createFunction: @escaping (AssessmentType, String, String, String, Date, Location) -> ()) {
        self.createFunction = createFunction
    }
    
    // MARK: - Functions
    
    func clinical() {
        assessmentType = .clinical
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            animationOffset = .zero
        }
    }
    
    func research() {
        assessmentType = .research
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            animationOffset = .zero
        }
    }
    
    func back() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            animationOffset = 200
        }
        assessmentType = nil
    }
    
    func create() {
        guard let location = location, let assessmentType = assessmentType else {
            // Location and assessment type should never be nil as the button is disabled if it was not set.
            return
        }
        createFunction(assessmentType, subject, instructor, administrator, date, location)
    }
}
