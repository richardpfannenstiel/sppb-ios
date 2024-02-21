//
//  GaitTestView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI

struct GaitTestView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let takingPositionText = "Please help the patient to take the start position.".localized
        static let positionDetectedText = "Start pose detected\nYou may start the test.".localized
        static let secondsLabel = "Seconds".localized
        static let redoLabel = "Redo".localized
    }
    
    @StateObject var model: GaitTestViewModel
    
    var body: some View {
        TestViewStructure(model: model) {
            VStack {
                switch model.progress {
                case .readingInstructions:
                    Image("speaking")
                        .resizable()
                        .flipped()
                        .scaledToFit()
                        .frame(width: 50)
                    Text(model.gaitTest.instructions)
                        .italic()
                        .multilineTextAlignment(.center)
                case .findingPose:
                    Text(Constant.takingPositionText)
                        .rounded(size: 20)
                        .multilineTextAlignment(.center)
                case .readyToStart:
                    progress
                    Text(Constant.positionDetectedText)
                        .rounded(size: 20)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                case .testOngoing, .testStopped:
                    progress
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
        }.overlay(
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor([.findingPose, .readyToStart, .testOngoing].contains(model.progress) ? .red : .clear)
                    .frame(width: width - 50, height: 10)
                    .cornerRadius(15)
                    .padding(.bottom, 50)
            }
        )
    }
    
    private var progress: some View {
        let radius: CGFloat = 150
        let textSize: CGFloat = 22
        
        return CircularProgress(radius: radius, textSize: textSize, ringPercentange: $model.ringPercentange, result: $model.test.result) {
            VStack {
                if let result = model.test.result {
                    Image(systemName: "\(result.failed ? "xmark": "checkmark").seal.fill")
                        .resizable()
                        .foregroundColor(result.failed ? .red : .blue)
                        .frame(width: radius / 3, height: radius / 3)
                }
                Text("\(String(format: "%.2f", model.time))")
                    .rounded(size: textSize, weight: .semibold)
                if model.test.result == nil {
                    Text(Constant.secondsLabel)
                        .rounded(size: textSize - 5)
                }
            }
        }
    }
}

struct GaitTestView_Previews: PreviewProvider {
    
    static let firstWalk = GaitTest(title: "", instructions: GaitTest.firstWalkInstructions)
    static let secondWalk = GaitTest(title: "", instructions: GaitTest.subsequentWalkInstructions)
    
    static var previews: some View {
        GaitTestView(model: GaitTestViewModel(for: Battery(tests: [firstWalk])))
    }
}
