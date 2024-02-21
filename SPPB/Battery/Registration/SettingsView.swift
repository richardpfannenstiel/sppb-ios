//
//  SettingsView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.08.23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("settings.showingPoseOverlay") var showingPoseOverlay = true
    @AppStorage("settings.disableSkippingTests") var disableSkippingTests = false
    
    var body: some View {
        VStack() {
            DescriptiveToggle(isOn: $disableSkippingTests,
                              title: "Disable Skipping Tests".localized,
                              description: "Skipping Tests Text".localized)
            DescriptiveToggle(isOn: $showingPoseOverlay,
                              title: "Show Pose Overlay".localized,
                              description: "Pose Overlay Text".localized)
        }.frame(width: width - 50)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
