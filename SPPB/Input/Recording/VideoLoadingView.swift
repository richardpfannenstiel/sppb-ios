//
//  VideoLoadingView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 18.09.23.
//

import SwiftUI

struct VideoLoadingView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let loadingLabel = "Loading".localized
    }
    
    @Binding var progress: CGFloat?
    
    var body: some View {
        VStack {
            HStack {
                Text(Constant.loadingLabel)
                    .rounded()
                Spacer()
            }
            ProgressView(value: progress)
        }
    }
}

struct VideoLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VideoLoadingView(progress: .constant(0.25))
            .padding()
    }
}
