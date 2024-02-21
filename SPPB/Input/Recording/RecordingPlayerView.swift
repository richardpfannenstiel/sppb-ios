//
//  RecordingPlayerView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 27.09.23.
//

import SwiftUI

struct RecordingPlayerView<Content: View>: View {
    
    @StateObject var viewModel: RecordingPlayerViewModel
    let content: Content
    let namespace: Namespace.ID

    var body: some View {
        ZStack {
            ImageAnnotationViewRepresentable(image: $viewModel.currentImage, imageWidth: $viewModel.width, imageHeight: $viewModel.height, orientation: $viewModel.orientation, poses: $viewModel.poses)
                .gesture(
                    TapGesture()
                        .onEnded({
                            viewModel.toggleControls()
                        })
                )
                .ignoresSafeArea()
            videoControlOptions
                .opacity(viewModel.showingPlayerControls ? 1 : 0)
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
    
    private var videoControlOptions: some View {
        ZStack {
            if viewModel.playingRecording {
                Button(action: viewModel.pause) {
                    Image(systemName: "pause.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 50, height: 50)
                }.buttonStyle(FlatGlassCircularButton())
            } else {
                Button(action: viewModel.play) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .matchedGeometryEffect(id: "CROP", in: namespace)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 50, height: 50)
                }.buttonStyle(FlatGlassCircularButton())
            }
        }
    }

    private var inputOptions: some View {
        VStack {
            Button(action: viewModel.showCamera) {
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
                .disabled(viewModel.cameraButtonDisabled)
            Button(action: viewModel.showGallery) {
                Image(systemName: "photo.stack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
                .disabled(viewModel.galleryButtonDisabled)
        }
    }
    
    private var nextButton: some View {
        Button(action: viewModel.next) {
            HStack {
                Spacer()
                Text(viewModel.nextButtonLabel)
                    .rounded()
                Spacer()
            }
        }.buttonStyle(FlatGlassButton(tint: viewModel.nextButtonDisabled ? .gray : .blue))
            .disabled(viewModel.nextButtonDisabled)
    }
}
