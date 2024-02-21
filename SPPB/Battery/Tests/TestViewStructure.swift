//
//  TestViewStructure.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 29.07.23.
//

import SwiftUI

struct TestViewStructure<Content: View>: View {
    
    @ObservedObject var model: TestViewModel
    @ViewBuilder var content: Content
    
    @Namespace var animation
    
    var body: some View {
        ZStack {
            switch model.inputState {
            case .camera:
                CameraInputView(model: model, content: content, namespace: animation)
            case .loadRecording:
                RecordingLoadingView(model: model, namespace: animation)
            case .analyzeRecording:
                RecordingAnalyzerView(viewModel: RecordingAnalyzerViewModel(model: model), namespace: animation)
            case .playRecording:
                RecordingPlayerView(viewModel: RecordingPlayerViewModel(model: model), content: content, namespace: animation)
            }
        }.solidSheet(isPresented: $model.showingGallerySelection) {
            VideoPicker(initiationHandler: { success in
                if success {
                    model.loadRecording()
                }
            }, completionHandler: { result in
                model.processPickerResult(with: result)
            }, displayProgress: { progress in
                model.updateRecordingLoadingProgress(with: progress)
            }).edgesIgnoringSafeArea([.bottom])
        }.dynamicSheet(isPresented: $model.showingReasonSelection) {
            VStack {
                Text("Reason for not Completing the Test".localized)
                    .rounded(size: 20, weight: .semibold)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 30)
                ForEach(ResultReason.manualSelectionReasons, id: \.rawValue) { reason in
                    Button(action: { model.setFailedReason(to: reason) }) {
                        HStack {
                            Spacer()
                            Text(reason.label)
                                .rounded()
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }.buttonStyle(FlatSolidButton())
                }
            }.frame(width: width - 50)
        }
    }
}
