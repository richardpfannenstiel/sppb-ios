//
//  ChairStandTestView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 08.07.23.
//

import SwiftUI

struct ChairStandTestView: View {
    
    @StateObject var model: ChairStandTestViewModel
    
    var body: some View {
        TestViewStructure(model: model) {
            switch model.chairStandTest.testType {
            case .single:
                SingleChairStandView(model: model)
            case .repeated:
                RepeatedChairStandView(model: model)
            }
        }
//        .overlay(
//            ZStack {
//                if let coordinate = model.previewHipCoordinate,
//                   let area = model.previewHipCoordinateArea {
//                    VStack {
//                        Rectangle()
//                            .foregroundColor(.red.opacity(0.3))
//                            .frame(width: width - 50, height: area)
//                            .cornerRadius(15)
//                            .padding(.top, coordinate - area)
//                        Spacer()
//                    }
//
//                }
//            }.edgesIgnoringSafeArea([.top, .bottom])
//        )
    }
}

struct ChairStandTestView_Previews: PreviewProvider {
    static let singleChairStand: Test = ChairStandTest(title: "Single Chair Stand", instructions: "", testType: .single)
    
    static let repeatedChairStand: Test = ChairStandTest(title: "Repeated Chair Stand", instructions: "", testType: .repeated)
    
    static var previews: some View {
        ChairStandTestView(model: ChairStandTestViewModel(for: Battery(tests: [singleChairStand])))
    }
}
