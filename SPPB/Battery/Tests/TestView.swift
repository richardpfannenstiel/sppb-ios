//
//  TestView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI

struct TestView: View {
    
    let battery: Battery
    
    var body: some View {
        if let test = battery.nextTest {
            if test is BalanceTest {
                BalanceTestView(model: BalanceTestViewModel(for: battery))
            }
            if test is GaitTest {
                GaitTestView(model: GaitTestViewModel(for: battery))
            }
            if test is ChairStandTest {
                ChairStandTestView(model: ChairStandTestViewModel(for: battery))
            }
        } else {
            ResultsView(model: ResultsViewModel(for: battery))
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(battery: Battery())
    }
}
