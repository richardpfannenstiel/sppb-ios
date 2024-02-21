//
//  AnimationPlayer.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 29.07.23.
//

import SwiftUI
import AVKit
import Combine

struct AnimationPlayer: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let loadingLabel = "Loading".localized
    }
    
    // MARK: - Stored Properties
    
    let url: URL
    
    @State var player: AVPlayer?
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        if let player = player {
            PlayerViewRepresentable(player)
                .transition(.opacity.animation(.easeInOut(duration: 1)))
                .padding(.top, 50)
                .onDisappear {
                    stopAnimation()
                }
        } else {
            ProgressView {
                Text(Constant.loadingLabel)
                    .rounded()
            }.onAppear {
                loadAnimation(at: url, withRate: 0.9)
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadAnimation(at url: URL, withRate rate: Float = 0.8) {
        DispatchQueue.main.async { [self] in
            player = AVPlayer(url: url)

            guard let player = player,
                  let duration = player.currentItem?.asset.duration.seconds else {
                return
            }

            player.play()
            player.rate = rate * 1.1

            Timer.publish(every: TimeInterval(duration / Double(rate)), on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if player.rate < 0 {
                        player.rate = rate
                    } else {
                        player.rate = -rate
                    }
                }
                .store(in: &cancellables)
        }
    }

    private func stopAnimation() {
        DispatchQueue.main.async { [self] in
            cancellables.first?.cancel()
            cancellables.removeAll()
            player = nil
        }
    }
}

struct AnimationPlayer_Previews: PreviewProvider {
    static var previews: some View {
        AnimationPlayer(url: BalancePose.side_by_side.animationResource!)
    }
}
