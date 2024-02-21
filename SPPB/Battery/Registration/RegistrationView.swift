//
//  RegistrationView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import SwiftUI

struct RegistrationView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let titleLabel = "What type of assessment are you conducting?".localized
        static let researchLabel = "Research".localized
        static let clinicalLabel = "Clinical".localized
        static let continueLabel = "Continue".localized
    }
    
    @StateObject var model: RegistrationModel
    @State var showing = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let assessmentType = model.assessmentType {
                FlatGlassBackButton(action: model.back)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                Spacer()
                switch assessmentType {
                case .research:
                    ResearchRegistrationView(date: $model.date, subjectID: $model.subject, investigator: $model.instructor, administrator: $model.administrator, location: $model.location)
                        .offset(y: model.animationOffset)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                case .clinical:
                    ClinicalRegistrationView(date: $model.date, patient: $model.subject, physician: $model.instructor, administrator: $model.administrator, location: $model.location)
                        .offset(y: model.animationOffset)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
                Spacer()
                if [.research, .clinical].contains(assessmentType) {
                    continueButton
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
                
            } else {
                assessmentSelection
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }.background(SimpleBackgroundView(backgroundColors: [.white, .cyan, .white]))
    }
    
    private var continueButton: some View {
        Button(action: model.create) {
            Text(Constant.continueLabel)
                .rounded()
                .frame(width: width - 50)
        }.buttonStyle(FlatGlassButton(tint: model.buttonDisabled ? .gray : .blue))
            .disabled(model.buttonDisabled)
    }
    
    private var settingsButton: some View {
        FlatGlassSettingsButton(action: { showing.toggle() })
            .dynamicSheet(isPresented: $showing) {
                SettingsView()
                    .padding(.top, 50)
            }
    }
    
    private var assessmentSelection: some View {
        VStack {
            Text(Constant.titleLabel)
                .rounded(size: 35, weight: .semibold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .padding(.horizontal)
            settingsButton
            Spacer()
            VStack(spacing: 20) {
                Button(action: model.research) {
                    Text(Constant.researchLabel)
                        .rounded()
                        .frame(width: width - 50)
                }.buttonStyle(FlatGlassButton())
                Button(action: model.clinical) {
                    Text(Constant.clinicalLabel)
                        .rounded()
                        .frame(width: width - 50)
                }.buttonStyle(FlatGlassButton())
            }
            Spacer()
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(model: RegistrationModel(createFunction: {_,_,_,_,_,_  in }))
    }
}
