//
//  ClinicalRegistrationView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import SwiftUI

struct ClinicalRegistrationView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let dateLabel = "Date".localized
        static let patientLabel = "Patient".localized
        static let physicianLabel = "Physician".localized
        static let administratorLabel = "Administrator".localized
    }
    
    // MARK: - State
    
    @Binding var date: Date
    @Binding var patient: String
    @Binding var physician: String
    @Binding var administrator: String
    @Binding var location: Location?
    
    var body: some View {
        VStack {
            DatePicker(Constant.dateLabel, selection: $date)
                .padding(10)
                .tile()
            TextField(Constant.patientLabel, text: $patient)
                .padding()
                .tile()
            TextField(Constant.physicianLabel, text: $physician)
                .padding()
                .tile()
            TextField(Constant.administratorLabel, text: $administrator)
                .padding()
                .tile()
            LocationSelectionView(location: $location)
        }
    }
}

struct ClinicalRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        ClinicalRegistrationView(date: .constant(Date()), patient: .constant(""), physician: .constant(""), administrator: .constant(""), location: .constant(nil))
            .background(BackgroundView())
    }
}
