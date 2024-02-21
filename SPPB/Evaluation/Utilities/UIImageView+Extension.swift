//
//  UIImageView+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 19.06.23.
//
//  The function defined in this extension has been copied from Nathan F. provided in an answer of the following post.
//  https://stackoverflow.com/a/53011187
//

import UIKit
import AVKit

extension UIImageView {
    /// Retrieve the scaled size of the image within this ImageView.
    /// - Returns: A CGRect representing the size of the image after scaling or nil if no image is set.
    func getScaledImageSize() -> CGRect? {
        if let image = self.image {
            return AVMakeRect(aspectRatio: image.size, insideRect: self.frame);
        }
        return nil;
    }
}
