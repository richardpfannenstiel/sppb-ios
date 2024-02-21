//
//  PlayerView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 12.07.23.
//
//  The class defined in this file has mainly been copied from Raja Kishan provided in an answer of the following post.
//  https://stackoverflow.com/a/68327532
//


import AVKit
import UIKit

class PlayerUIView: UIView {
    
    // MARK: Class Property
    
    let playerLayer = AVPlayerLayer()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        self.playerSetup(player: player)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Life-Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        
    }
    
    // MARK: Class Methods
    
    private func playerSetup(player: AVPlayer) {
        playerLayer.player = player
        player.actionAtItemEnd = .none
        layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = UIColor.white.cgColor
    }
}
