//
//  PlayerViewRepresentable.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 12.07.23.
//
//  The class defined in this file has mainly been copied from Raja Kishan provided in an answer of the following post.
//  https://stackoverflow.com/a/68327532
//

import SwiftUI
import AVKit

struct PlayerViewRepresentable: UIViewRepresentable {
    
    private var player: AVPlayer
    
    init(_ player: AVPlayer) {
        self.player = player
    }
    
    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(player: player)
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: UIViewRepresentableContext<PlayerViewRepresentable>) {
        uiView.playerLayer.player = player
    }
}
