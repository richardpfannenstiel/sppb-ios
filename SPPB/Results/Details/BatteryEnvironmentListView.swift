//
//  BatteryEnvironmentListView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.10.23.
//

import SwiftUI

struct BatteryEnvironmentListView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let dateLabel = "Date".localized
        static let locationLabel = "Location".localized
        static let subjectIDLabel = "SubjectID".localized
        static let patientLabel = "Patient".localized
        static let physicianLabel = "Physician".localized
        static let investigatorLabel = "Investigator".localized
        static let administratorLabel = "Administrator".localized
    }
    
    // MARK: - Stored Properties
    
    let assessmentType: AssessmentType
    let date: Date
    let subject: String
    let instructor: String
    let administrator: String
    let location: Location
    
    var body: some View {
        VStack {
            HStack {
                Text(assessmentType == .clinical ? Constant.patientLabel : Constant.subjectIDLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text(subject)
                    .rounded()
            }
            Divider()
            HStack {
                Text(assessmentType == .clinical ? Constant.physicianLabel : Constant.investigatorLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text(instructor)
                    .rounded()
            }
            Divider()
            HStack {
                Text(Constant.administratorLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text(administrator)
                    .rounded()
            }
            Divider()
            HStack {
                Text(Constant.locationLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text(location.label)
                    .rounded()
            }
            Divider()
            HStack {
                Text(Constant.dateLabel)
                    .rounded(weight: .semibold)
                Spacer()
                Text(date.formatted())
                    .rounded()
            }
        }
    }
}

struct BatteryEnvironmentListView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryEnvironmentListView(assessmentType: .clinical, date: Date(), subject: "Jonas Stefano", instructor: "Lukas Kübbers", administrator: "Mara Leimer", location: .medicalFacility)
            .padding(.horizontal, 50)
    }
}
