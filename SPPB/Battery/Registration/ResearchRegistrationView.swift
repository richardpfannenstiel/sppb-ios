//
//  ResearchRegistrationView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import SwiftUI

struct ResearchRegistrationView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let dateLabel = "Date".localized
        static let subjectIDLabel = "SubjectID".localized
        static let investigatorLabel = "Investigator".localized
        static let administratorLabel = "Administrator".localized
    }
    
    // MARK: - State
    
    @Binding var date: Date
    @Binding var subjectID: String
    @Binding var investigator: String
    @Binding var administrator: String
    @Binding var location: Location?
    
    var body: some View {
        VStack {
            DatePicker(Constant.dateLabel, selection: $date)
                .padding(10)
                .tile()
            TextField(Constant.subjectIDLabel, text: $subjectID)
                .padding()
                .tile()
            TextField(Constant.investigatorLabel, text: $investigator)
                .padding()
                .tile()
            TextField(Constant.administratorLabel, text: $administrator)
                .padding()
                .tile()
            LocationSelectionView(location: $location)
        }
    }
}

struct ResearchRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        ResearchRegistrationView(date: .constant(Date()), subjectID: .constant(""), investigator: .constant(""), administrator: .constant(""), location: .constant(nil))
            .background(BackgroundView())
    }
}
