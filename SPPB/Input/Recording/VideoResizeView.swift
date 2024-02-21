//
//  VideoResizeView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 19.09.23.
//

import SwiftUI
import AVKit

struct VideoResizeView: View {
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    @State var previewImage: Image? = nil
    @State var croppedImage: Image? = nil
    @State var imageOrientation: Image.Orientation = .up
    let recording: URL
    
    var body: some View {
        ZStack {
            if let image = previewImage {
                GeometryReader {
                    let size = $0.size
                    
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .onChange(of: isInteracting, perform: { newValue in
                            if !newValue {
                                lastStoredOffset = offset
                            }
                        })
                        .overlay(
                            GeometryReader { proxy in
                                let rect = proxy.frame(in: .named ("TEST"))
                                Color.clear
                                    .onChange(of: isInteracting) { newValue in
                                        withAnimation(.easeInOut(duration: 0.2)) {
//                                            if rect.minX > 0 {
//                                                offset.width = (offset.width - rect.minX)
//                                            }
                                            
                                            if rect.minY > 0 {
                                                offset.height = (offset.height - rect.minY)
                                            }
                                            
//                                            if rect.maxX < size.width {
//                                                offset.width = (rect.minX - offset.width)
//                                            }
                                            
                                            if rect.maxY < size.height {
                                                offset.height = (rect.minY - offset.height)
                                            }
                                        }
                                        
                                        if !newValue {
                                            lastStoredOffset = offset
                                        }
                                    }
                            }
                        )
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .updating($isInteracting, body: { _, out, _ in
                                    out = true
                                })
                                .onChanged({ value in
                                    let translation = value.translation
                                    offset = CGSize(width: translation.width + lastStoredOffset.width, height: translation.height + lastStoredOffset.height)
                                })
                        )
                        .gesture(
                            MagnificationGesture()
                                .updating($isInteracting, body: { _, out, _ in
                                    out = true
                                })
                                .onChanged({ value in
                                    let updatedScale = value + lastScale
                                    scale = max(updatedScale, 1)
                                })
                                .onEnded({ value in
                                    withAnimation(.interpolatingSpring(stiffness: 50, damping: 8)) {
                                        if scale < 1 {
                                            scale = 1
                                            lastScale = 0
                                        } else {
                                            lastScale = scale - 1
                                        }
                                    }
                                })
                        ).coordinateSpace(name: "TEST")
                }
            }
            VStack {
                Spacer()
                rotateOptions
            }
        }.onAppear(perform: showPreviewImage )
    }
    
    private var rotateOptions: some View {
        HStack {
            Button(action: { rotateClockwise() }) {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
            Button(action: { flipHorizontally() }) {
                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
            Button(action: { rotateCounterClockwise() }) {
                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 50, height: 50)
            }.buttonStyle(FlatGlassCircularButton())
                .frame(width: 50, height: 50)
        }
    }
    
    func resetResize() {
        scale = 1
        lastScale = 0
        offset = .zero
        lastStoredOffset = .zero
    }
    
    func rotateClockwise() {
        imageOrientation = imageOrientation.rotatedClockwise
        resetResize()
        showPreviewImage()
    }
    
    func rotateCounterClockwise() {
        imageOrientation = imageOrientation.rotatedCounterClockwise
        resetResize()
        showPreviewImage()
    }
    
    func flipHorizontally() {
        imageOrientation = imageOrientation.horizontallyFlipped
        showPreviewImage()
    }
    
    func showPreviewImage() {
        let movie: AVURLAsset = AVURLAsset(url: recording)
        movie.loadTracks(withMediaType: .video) { tracks, error in
            guard let track = tracks?[0] else {
                print("No suitable track found.")
                return
            }
            
            var reader: AVAssetReader? = nil
            
            do {
                reader = try AVAssetReader(asset: movie)
            } catch {
                print("AVReader could not be initialized.")
            }
            
            let settings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
            let trackOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
            reader?.add(trackOutput)
            reader?.startReading()
            
            if let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    print("Failed to get image buffer from sample buffer.")
                    return
                }
                
                let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
                let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
                DispatchQueue.main.async { [self] in
                    previewImage = convert(ciImage: ciImage, width: imageWidth, height: imageHeight, orientation: imageOrientation)
                }
            }
        }
    }
    
    private func convert(ciImage: CIImage, width: CGFloat, height: CGFloat, orientation: Image.Orientation) -> Image {
        let context = CIContext(options: nil)
        context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height))
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image = Image(cgImage, scale: 1, orientation: orientation, label: Text(""))
        return image
    }
}
