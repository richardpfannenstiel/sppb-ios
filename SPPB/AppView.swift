//
//  BatteryView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 05.07.23.
//

import SwiftUI

struct AppView: View {
    
    @StateObject var battery = Battery()
    
    var body: some View {
        if battery.isEnvironmentSet {
            if battery.showingIntroduction {
                BatteryIntroductionView(model: BatteryIntroductionViewModel(startAction: battery.start))
            } else {
                if battery.showingProgress {
                    BatteryProgressView(model: BatteryProgressModel(for: battery))
                } else {
                    TestView(battery: battery)
                }
            }
        } else {
            RegistrationView(model: RegistrationModel(createFunction: battery.setEnvironment))
        }
    }
}

struct BatteryView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
