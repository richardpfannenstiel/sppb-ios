//
//  AVAssetTrack+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 26.09.23.
//

import AVKit

extension AVAssetTrack {
    
    var frameRate: Double {
        get async {
            do {
                return try await Double(self.load(.nominalFrameRate)).rounded(.up)
            } catch {
                return -1
            }
        }
    }
    
    var totalFrames: Int {
        get async {
            guard let asset = self.asset else {
                return -1
            }
            
            do {
                let duration = try await Float(CMTimeGetSeconds(asset.load(.duration)))
                let frameRate = try await Float(self.load(.nominalFrameRate)).rounded(.up)
                return Int(duration * frameRate)
            } catch {
                return -1
            }
        }
        
    }
}
