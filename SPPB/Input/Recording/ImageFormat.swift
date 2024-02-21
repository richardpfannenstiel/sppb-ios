//
//  ImageFormat.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 27.09.23.
//

import SwiftUI

struct ImageFormat {
    let scale: CGFloat
    let offset: CGSize
    let dimensions: CGSize
    let orientation: Image.Orientation
    
    func crop(image: CIImage) -> CIImage? {
        let width = dimensions.width
        let height = dimensions.height
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let cropWidth = min(width, height) * (screenWidth / screenHeight)
        let cropHeight = min(width, height)
        
        let offsetMultiplier = height / (screenHeight / 2)
        let middleX = (width / 2)
        let middleY = (height / 2)
        let horizontalAlignment = (cropWidth / 2) / scale
        let verticalAlignment = (cropHeight / 2) / scale
        let horizontalOffset = (offset.width * offsetMultiplier) / scale
        let verticalOffset = (offset.height * offsetMultiplier) / scale
        
        var cropRect: CGRect
        
        switch orientation {
        case .up:
            cropRect = CGRect(
                x: (middleX - horizontalOffset) - horizontalAlignment,
                y: (middleY - verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .upMirrored:
            cropRect = CGRect(
                x: (middleX + horizontalOffset) - horizontalAlignment,
                y: (middleY - verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .down:
            cropRect = CGRect(
                x: (middleX + horizontalOffset) - horizontalAlignment,
                y: (middleY + verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .downMirrored:
            cropRect = CGRect(
                x: (middleX - horizontalOffset) - horizontalAlignment,
                y: (middleY + verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .left:
            cropRect = CGRect(
                x: (middleX + verticalOffset) - verticalAlignment,
                y: (middleY - horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        case .leftMirrored:
            cropRect = CGRect(
                x: (middleX - verticalOffset) - verticalAlignment,
                y: (middleY - horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        case .right:
            cropRect = CGRect(
                x: (middleX - verticalOffset) - verticalAlignment,
                y: (middleY + horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        case .rightMirrored:
            cropRect = CGRect(
                x: (middleX + verticalOffset) - verticalAlignment,
                y: (middleY + horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        }
        
        // Crop image to specified scale and offset.
        let croppedImage = image.cropped(to: cropRect)
        return croppedImage
    }
    
    func crop(image: CGImage) -> CGImage? {
        let width = dimensions.width
        let height = dimensions.height
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let cropWidth = min(width, height) * (screenWidth / screenHeight)
        let cropHeight = min(width, height)
        
        let offsetMultiplier = height / (screenHeight / 2)
        let middleX = (width / 2)
        let middleY = (height / 2)
        let horizontalAlignment = (cropWidth / 2) / scale
        let verticalAlignment = (cropHeight / 2) / scale
        let horizontalOffset = (offset.width * offsetMultiplier) / scale
        let verticalOffset = (offset.height * offsetMultiplier) / scale
        
        var cropRect: CGRect
        
        switch orientation {
        case .up:
            cropRect = CGRect(
                x: (middleX - horizontalOffset) - horizontalAlignment,
                y: (middleY - verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .upMirrored:
            cropRect = CGRect(
                x: (middleX + horizontalOffset) - horizontalAlignment,
                y: (middleY - verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .down:
            cropRect = CGRect(
                x: (middleX + horizontalOffset) - horizontalAlignment,
                y: (middleY + verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .downMirrored:
            cropRect = CGRect(
                x: (middleX - horizontalOffset) - horizontalAlignment,
                y: (middleY + verticalOffset) - verticalAlignment,
                width: cropWidth / scale,
                height: cropHeight / scale
            ).integral
        case .left:
            cropRect = CGRect(
                x: (middleX + verticalOffset) - verticalAlignment,
                y: (middleY - horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        case .leftMirrored:
            cropRect = CGRect(
                x: (middleX - verticalOffset) - verticalAlignment,
                y: (middleY - horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        case .right:
            cropRect = CGRect(
                x: (middleX - verticalOffset) - verticalAlignment,
                y: (middleY + horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        case .rightMirrored:
            cropRect = CGRect(
                x: (middleX + verticalOffset) - verticalAlignment,
                y: (middleY + horizontalOffset) - horizontalAlignment,
                width: cropHeight / scale,
                height: cropWidth / scale
            ).integral
        }
        
        // Crop image to specified scale and offset.
        let croppedImage = image.cropping(to: cropRect)
        return croppedImage
    }
}
