//
//  BalanceTestView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI
import AVKit
import Combine

struct BalanceTestView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let takingPositionText = "Please help the patient to get into the position.".localized
        static let poseDetectedText = "Pose detected\nYou may start the test.".localized
        static let secondsLabel = "Seconds".localized
        static let redoLabel = "Redo".localized
        static let showModelLabel = "Show Model".localized
        static let loadingLabel = "Loading".localized
    }
    
    @StateObject var model: BalanceTestViewModel
    
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
                    Text(model.balanceTest.instructions)
                        .italic()
                        .multilineTextAlignment(.center)
                    modelAnimation
                case .findingPose:
                    Text(Constant.takingPositionText)
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
    }
    
    private var progress: some View {
        let radius: CGFloat = 150
        let textSize: CGFloat = 22
        
        return CircularProgress(radius: radius, textSize: textSize, ringPercentange: $model.ringPercentange, result: $model.balanceTest.result) {
            VStack {
                if let result = model.balanceTest.result {
                    Image(systemName: "\(result.failed ? "xmark": "checkmark").seal.fill")
                        .resizable()
                        .foregroundColor(result.failed ? .red : .blue)
                        .frame(width: radius / 3, height: radius / 3)
                }
                Text("\(String(format: "%.2f", model.time))")
                    .rounded(size: textSize, weight: .semibold)
                if model.balanceTest.result == nil {
                    Text(Constant.secondsLabel)
                        .rounded(size: textSize - 5)
                }
            }
        }
    }
    
    private var modelAnimation: some View {
        Button(action: model.showAnimation) {
            HStack {
                Image(systemName: "figure.stand")
                Text(Constant.showModelLabel)
                    .rounded(size: 20)
            }.padding(.top)
        }.sheet(isPresented: $model.showingAnimation) {
            if let url = model.balanceTest.pose.animationResource {
                AnimationPlayer(url: url)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(50)
                    .presentationBackground(.white)
                    .preferredColorScheme(.light)
            }
        }
    }
}

struct BalanceTestView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceTestView(model: BalanceTestViewModel(for: Battery(tests: [BalanceTest(title: "", instructions: BalancePose.side_by_side.instructions, pose: .side_by_side)])))
    }
}
