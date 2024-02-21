//
//  SingleChairStand.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 28.07.23.
//

import SwiftUI

struct SingleChairStandView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let takingSitText = "Please ask the patient to sit down onto the chair.".localized
        static let foldingArmsText = "Please ask the patient to fold their arms across the chest.".localized
        static let poseDetectedText = "Start position taken\nYou may start the test.".localized
        static let remindToNotUseArmsText = "Please remind the patient not to use their arms.".localized
        static let redoLabel = "Redo".localized
        static let standLabel = "Stand up".localized
        static let readyLabel = "Ready to start".localized
    }
    
    @ObservedObject var model: ChairStandTestViewModel
    
    var body: some View {
        VStack {
            switch model.progress {
            case .readingInstructions:
                Image("speaking")
                    .resizable()
                    .flipped()
                    .scaledToFit()
                    .frame(width: 50)
                Text(model.chairStandTest.instructions)
                    .italic()
                    .multilineTextAlignment(.center)
            case .awaitTakingSit:
                Text(Constant.takingSitText)
                    .rounded(size: 20)
                    .multilineTextAlignment(.center)
            case .awaitFoldingArms:
                Text(Constant.foldingArmsText)
                    .rounded(size: 20)
                    .multilineTextAlignment(.center)
            case .readyToStart:
                progress
                Text(Constant.poseDetectedText)
                    .rounded(size: 20)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            case .testOngoing, .testStopped:
                progress
                if model.remindArmPosition {
                    Text(Constant.remindToNotUseArmsText)
                        .rounded(size: 20)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
                if let result = model.test.result {
                    // Test result was set.
                    Text(result.comment.rawValue)
                        .rounded(size: 24, weight: .semibold)
                        .padding(.top)
                    Text(result.comment.feedback(for: model.test).replacingOccurrences(of: "$time", with: String(format: "%.0f", model.time.rounded(.down))))
                        .rounded(size: 20)
                        .multilineTextAlignment(.center)
                    Button(action: model.redoTest) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text(Constant.redoLabel)
                                .rounded(size: 20)
                        }.padding()
                    }
                }
            }
        }
    }
    
    private var progress: some View {
        let radius: CGFloat = 150
        let textSize: CGFloat = 22
        
        return CircularProgress(radius: radius, textSize: textSize, ringPercentange: $model.ringPercentange, result: $model.chairStandTest.result) {
            VStack {
                if let result = model.chairStandTest.result {
                    Image(systemName: "\(result.failed ? "xmark": "checkmark").seal.fill")
                        .resizable()
                        .foregroundColor(result.failed ? .red : .blue)
                        .frame(width: radius / 3, height: radius / 3)
                }

                if model.chairStandTest.result == nil {
                    let firstReadyWord = String(Constant.readyLabel.split(separator: " ").first ?? "")
                    let subsequentReadyWords = Constant.readyLabel.split(separator: " ").dropFirst().reduce("", { $0 + " " + $1})
                    
                    let firstStandupWord = String(Constant.standLabel.split(separator: " ").first ?? "")
                    let subsequentStandupWords = Constant.standLabel.split(separator: " ").dropFirst().reduce("", { $0 + " " + $1})
                    Text(model.progress == .readyToStart ? firstReadyWord : firstStandupWord)
                        .rounded(size: textSize, weight: .semibold)
                    Text(model.progress == .readyToStart ? subsequentReadyWords : subsequentStandupWords)
                        .rounded(size: textSize - 5)
                }
            }
        }
    }
}

struct SingleChairStandView_Previews: PreviewProvider {
    static let singleChairStand: Test = ChairStandTest(title: "Single Chair Stand", instructions: ChairStandTestType.single.instructions, testType: .single)
    
    static var previews: some View {
        ChairStandTestView(model: ChairStandTestViewModel(for: Battery(tests: [singleChairStand])))
    }
}
