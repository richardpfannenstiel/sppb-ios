//
//  BatteryIntroductionView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//
//  The icon used in this view was created by Abdul-Aziz - Flaticon.
//  https://www.flaticon.com/free-icons/speak
//

import SwiftUI

struct BatteryIntroductionView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let introductionText = "Introduction Text".localized
        static let explanationText = "Explanation Text".localized
        static let startButtonLabel = "Let's Start".localized
        static let understoodButtonLabel = "I understand".localized
    }
    
    @StateObject var model: BatteryIntroductionViewModel
    
    var body: some View {
        VStack {
            Spacer()
            if model.showingInstructions {
                instructions
                    .offset(y: model.animationOffset)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            } else {
                explanation
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
            Spacer()
            Button(action: model.next) {
                Text(model.showingInstructions ? Constant.startButtonLabel : Constant.understoodButtonLabel)
                    .rounded()
                    .frame(width: width - 50)
            }.buttonStyle(FlatGlassButton(tint: .blue))
        }.background(BackgroundView())
    }
    
    private var explanation: some View {
        Text(Constant.explanationText)
            .rounded(size: 20)
            .multilineTextAlignment(.center)
            .padding()
            .frame(width: width - 50)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
    }
    
    private var instructions: some View {
        VStack {
            Image("speaking")
                .resizable()
                .flipped()
                .scaledToFit()
                .frame(width: 50)
            Text("\(Constant.introductionText)")
                .italic()
                .multilineTextAlignment(.center)
        }.padding()
            .frame(width: width - 50)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
    }
}

struct BatteryIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryIntroductionView(model: BatteryIntroductionViewModel(startAction: {}))
    }
}
