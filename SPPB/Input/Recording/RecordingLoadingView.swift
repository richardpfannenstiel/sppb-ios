//
//  RecordingLoadingView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 20.09.23.
//

import SwiftUI

struct RecordingLoadingView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let loadingLabel = "Loading".localized
    }
    
    @ObservedObject var model: TestViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(Constant.loadingLabel)
                        .rounded()
                    Spacer()
                }
                ProgressView(value: model.recordingLoadingProgress)
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
            .frame(width: width - 50)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            Spacer()
        }
    }
}
