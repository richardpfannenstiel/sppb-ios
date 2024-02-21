//
//  RepeatedChairStandView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 09.08.23.
//

import SwiftUI

struct RepeatedChairStandView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let takingSitText = "Please ask the patient to sit down onto the chair.".localized
        static let foldingArmsText = "Please ask the patient to fold their arms across the chest.".localized
        static let poseDetectedText = "Start position taken\nYou may start the test.".localized
        static let remindToNotUseArmsText = "Please remind the patient not to use their arms.".localized
        static let repetitionsLabel = "Repetitions".localized
        static let redoLabel = "Redo".localized
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
                Text(model.chairStandTest.testType.instructions)
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
                if let result = model.test.result {
                    Image(systemName: "\(result.failed ? "xmark": "checkmark").seal.fill")
                        .resizable()
                        .foregroundColor(result.failed ? .red : .blue)
                        .frame(width: radius / 3, height: radius / 3)
                }
                Text("\(model.counter)/\(model.chairStandTest.repetitions)")
                    .rounded(size: textSize, weight: .semibold)
                if model.chairStandTest.result == nil {
                    Text(Constant.repetitionsLabel)
                        .rounded(size: textSize - 5)
                }
            }
        }
    }
}


struct RepeatedChairStandView_Previews: PreviewProvider {
    static let repeatedChairStand: Test = ChairStandTest(title: "Repeated Chair Stand", instructions: "", testType: .repeated)
    
    static var previews: some View {
        ChairStandTestView(model: ChairStandTestViewModel(for: Battery(tests: [repeatedChairStand])))
    }
}
