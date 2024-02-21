//
//  RecordingAnalyzerView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 20.09.23.
//

import SwiftUI
import AVKit

struct RecordingAnalyzerView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let instructions = "Resize and align the frame to focus the patient.".localized
        static let imageFailedToLoad = "Image could not be loaded.".localized
        static let analyzeLabel = "Analyze".localized
        static let analyzingLabel = "Analyzing".localized
        static let previewRectIdentifier = "PREVIEW"
        static let cropImageIdentifier = "CROP"
    }
    
    @StateObject var viewModel: RecordingAnalyzerViewModel
    @GestureState var isInteracting: Bool = false
    let namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            cropView
            VStack {
                islandContent
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                    .frame(width: width - 50)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                Spacer()
                HStack(alignment: .bottom, spacing: 20) {
                    analyzeButton
                    if viewModel.stage == .positioning {
                        inputOptions
                    }
                }.frame(width: width - 50)
            }
        }.onAppear(perform: viewModel.loadPreviewImage)
    }
    
    private var cropView: some View {
        ZStack {
            if let image = viewModel.analyzerPreview {
                if viewModel.stage != .analyzing {
                    image
                        .resizable()
                        .cornerRadius(15)
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: Constant.cropImageIdentifier, in: namespace)
                        .frame(width: width / 2, height: height / 2, alignment: .center)
                        .transition(.asymmetric(insertion: .identity, removal: .scale))
                }
            } else {
                preview
                    .clipped()
                    .frame(height: height / 2)
                    .cornerRadius(15)
                    .transition(.opacity)
            }
        }
    }
    
    private var preview: some View {
        ZStack {
            if let image = viewModel.positionPreview {
                GeometryReader {
                    let size = $0.size
                    
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .onChange(of: isInteracting, perform: { newValue in
                            if !newValue {
                                viewModel.lastStoredOffset = viewModel.offset
                            }
                        })
                        .overlay(
                            GeometryReader { proxy in
                                let rect = proxy.frame(in: .named(Constant.previewRectIdentifier))
                                Color.clear
                                    .onChange(of: isInteracting) { newValue in
                                        if !newValue {
                                            viewModel.lastStoredOffset = viewModel.offset
                                        }
                                    }
                            }
                        )
                        .scaleEffect(viewModel.scale)
                        .offset(viewModel.offset)
                        .coordinateSpace(name: Constant.previewRectIdentifier)
                }
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.black.opacity(0.5))
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: width / 2, height: height / 2)
                        .blendMode(.destinationOut)
                        .overlay(
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.white, lineWidth: 2)
                                if isInteracting {
                                    GridView()
                                        .transition(.opacity.animation(.easeInOut))
                                }
                            }
                        )
                }.compositingGroup()
                    .gesture(
                        DragGesture()
                            .updating($isInteracting, body: { _, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                let translation = value.translation
                                viewModel.offset = CGSize(width: translation.width + viewModel.lastStoredOffset.width, height: translation.height + viewModel.lastStoredOffset.height)
                            })
                    )
                    .gesture(
                        MagnificationGesture()
                            .updating($isInteracting, body: { _, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                let updatedScale = value + viewModel.lastScale
                                viewModel.scale = updatedScale
                            })
                            .onEnded({ value in
                                withAnimation(.easeInOut) {
                                    viewModel.lastScale = viewModel.scale - 1
                                }
                            })
                    )
                    .simultaneousGesture(
                        TapGesture(count: 2)
                            .onEnded({
                                withAnimation(.easeInOut) {
                                    viewModel.resetResize()
                                }
                            })
                    )
            } else {
                Text(Constant.imageFailedToLoad)
                    .rounded()
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var islandContent: some View {
        VStack {
            switch viewModel.stage {
            case .positioning:
                rotateOptions
            case .analyzing:
                if let image = viewModel.analyzerPreview {
                    image
                        .resizable()
                        .cornerRadius(15)
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: Constant.cropImageIdentifier, in: namespace)
                        .frame(width: width / 4, height: height / 4, alignment: .center)
                    HStack {
                        Text(Constant.analyzingLabel)
                            .rounded()
                        Spacer()
                        if viewModel.framesProcessed > 0 {
                            Text("\(viewModel.framesProcessed)/\(viewModel.totalVideoFrames)")
                                .rounded()
                        }
                    }
                    ProgressView(value: viewModel.analyzingProgress)
                }
            case .finished:
                HStack {
                    Text(Constant.analyzingLabel)
                        .rounded()
                    Spacer()
                    if viewModel.framesProcessed > 0 {
                        Text("\(viewModel.framesProcessed)/\(viewModel.totalVideoFrames)")
                            .rounded()
                    }
                }
                ProgressView(value: viewModel.analyzingProgress)
            }
        }
    }
    
    private var rotateOptions: some View {
        HStack {
            Button(action: viewModel.rotateClockwise) {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
            Button(action: viewModel.flipHorizontally) {
                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
            Button(action: viewModel.rotateCounterClockwise) {
                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
        }.disabled(viewModel.analyzerPreview != nil)
    }
    
    private var inputOptions: some View {
        VStack {
            Button(action: viewModel.closeRecording) {
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
                .disabled(viewModel.closeRecordingDisabled)
            Button(action: viewModel.showGallery) {
                Image(systemName: "photo.stack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
                .disabled(viewModel.galleryButtonDisabled)
        }.disabled(viewModel.analyzerPreview != nil)
    }
    
    private var analyzeButton: some View {
        Button(action: viewModel.analyze) {
            HStack {
                Spacer()
                switch viewModel.stage {
                case .positioning:
                    Text(Constant.analyzeLabel)
                        .rounded()
                case .analyzing, .finished:
                    Text(Constant.analyzingLabel)
                        .rounded()
                }
                Spacer()
            }
        }.buttonStyle(FlatGlassButton(tint: viewModel.stage != .positioning ? .gray : .blue))
            .disabled(viewModel.stage != .positioning)
    }
}
