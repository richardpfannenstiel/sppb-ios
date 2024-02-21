//
//  CameraInputView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 19.09.23.
//

import SwiftUI

struct CameraInputView<Content: View>: View {

    @ObservedObject var model: TestViewModel
    let content: Content
    let namespace: Namespace.ID

    var body: some View {
        ZStack {
            CameraViewRepresentable(model)
                .ignoresSafeArea()
            VStack {
                content
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                    .frame(width: width - 50)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    
                Spacer()
                HStack(alignment: .bottom, spacing: 20) {
                    nextButton
                    inputOptions
                }.frame(width: width - 50)
            }
        }
    }

    private var inputOptions: some View {
        VStack {
            Button(action: model.showGallery) {
                Image(systemName: "photo.stack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
                .disabled(model.galleryButtonDisabled)
            Button(action: model.flipCamera) {
                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
                .disabled(model.cameraButtonDisabled)
        }
    }
    
    private var nextButton: some View {
        Button(action: model.next) {
            HStack {
                Spacer()
                Text(model.nextButtonLabel)
                    .rounded()
                Spacer()
            }
        }.buttonStyle(FlatGlassButton(tint: model.nextButtonDisabled ? .gray : .blue))
            .disabled(model.nextButtonDisabled)
    }
}
