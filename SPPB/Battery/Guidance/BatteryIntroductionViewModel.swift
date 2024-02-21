//
//  BatteryIntroductionViewModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 13.07.23.
//

import SwiftUI

final class BatteryIntroductionViewModel: ViewModel {
    
    // MARK: - Stored Properties
    
    @Published var animationOffset: CGFloat = 200
    @Published var showingInstructions = false
    
    let startAction: () -> ()
    
    // MARK: - Computed Properties
    
    var buttonLabel: String {
        showingInstructions ? "Let's Start".localized : "I understand".localized
    }
    
    // MARK: - Initializer
    
    init(startAction: @escaping () -> ()) {
        self.startAction = startAction
    }
    
    // MARK: - Functions
    
    func next() {
        if showingInstructions {
            startAction()
        } else {
            showingInstructions = true
            withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
                animationOffset = .zero
            }
        }
    }
}
