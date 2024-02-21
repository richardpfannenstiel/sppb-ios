//
//  VideoPicker.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 18.09.23.
//

import SwiftUI
import PhotosUI
import Combine

struct VideoPicker: UIViewControllerRepresentable {
    
    var initiationHandler: (Bool) -> Void
    var completionHandler: (GalleryPickerResult) -> Void
    var displayProgress: (Progress) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let picker = PHPickerViewController(configuration: makeConfiguration())
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(initiationHandler: initiationHandler, completionHandler: completionHandler, displayProgress: displayProgress)
    }
    
    private func makeConfiguration() -> PHPickerConfiguration {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        return configuration
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        var initiationHandler: (Bool) -> Void
        var completionHandler: (GalleryPickerResult) -> Void
        var displayProgress: (Progress) -> Void
        
        var cancellables = Set<AnyCancellable>()
        
        init(initiationHandler: @escaping (Bool) -> Void, completionHandler: @escaping (GalleryPickerResult) -> Void, displayProgress: @escaping (Progress) -> Void) {
            self.initiationHandler = initiationHandler
            self.completionHandler = completionHandler
            self.displayProgress = displayProgress
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let result = results.first else {
                completionHandler(GalleryPickerResult(url: nil, message: "No video selected"))
                return
            }
            
            // Notify loading has commenced.
            initiationHandler(true)
            
            let progress = result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                do {
                    guard let url = url, error == nil else {
                        throw error ?? NSError(domain: NSFileProviderErrorDomain, code: -1, userInfo: nil)
                    }
                    let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                    try? FileManager.default.removeItem(at: localURL)
                    try FileManager.default.copyItem(at: url, to: localURL)
                    DispatchQueue.main.async { [self] in
                        completionHandler(GalleryPickerResult(url: localURL, message: "Selection successful"))
                    }
                } catch let error {
                    DispatchQueue.main.async { [self] in
                        completionHandler(GalleryPickerResult(url: nil, message: "Error: \(error.localizedDescription)"))
                    }
                }
            }
            
            Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [self] _ in
                    if progress.isFinished {
                        cancellables.first?.cancel()
                        cancellables.removeAll()
                    }
                    DispatchQueue.main.async { [self] in
                        displayProgress(progress)
                    }
                }.store(in: &cancellables)
        }
    }
}
