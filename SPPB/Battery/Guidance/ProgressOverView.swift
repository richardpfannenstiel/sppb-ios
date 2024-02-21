//
//  ProgressOverView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 07.08.23.
//

import SwiftUI

struct ProgressOverView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let balanceTestLabel = "Balance Tests".localized
        static let gaitSpeedTestLabel = "Gait Speed Tests".localized
        static let chairStandTestLabel = "Chair Stand Tests".localized
    }
    
    @ObservedObject var model: BatteryProgressModel
    let namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .frame(width: 10)
                    .offset(x: 20)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.blue)
                    .frame(width: 10, height: model.progressLineLength)
                    .offset(x: 20)
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 50)
                            Circle()
                                .foregroundColor(.blue)
                                .frame(width: model.balanceTestFinished ? 40 : 0)
                        }
                        HStack {
                            Spacer()
                            Text(Constant.balanceTestLabel)
                                .rounded()
                            Spacer()
                        }.padding()
                            .background(Color.white)
                            .cornerRadius(20)
                    }.matchedGeometryEffect(id: Constant.balanceTestLabel, in: namespace)
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 50)
                            Circle()
                                .foregroundColor(.blue)
                                .frame(width: model.gaitTestFinished ? 40 : 0)
                        }
                        HStack {
                            Spacer()
                            Text(Constant.gaitSpeedTestLabel)
                                .rounded()
                            Spacer()
                        }.padding()
                            .background(Color.white)
                            .cornerRadius(20)
                    }.matchedGeometryEffect(id: Constant.gaitSpeedTestLabel, in: namespace)
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 50)
                            Circle()
                                .foregroundColor(.blue)
                                .frame(width: model.chairStandTestFinished ? 40 : 0)
                        }
                        HStack {
                            Spacer()
                            Text(Constant.chairStandTestLabel)
                                .rounded()
                            Spacer()
                        }.padding()
                            .background(Color.white)
                            .cornerRadius(20)
                    }.matchedGeometryEffect(id: Constant.chairStandTestLabel, in: namespace)
                    Spacer()
                }
            }.padding(.horizontal)
                .onAppear {
                    model.setHeight(height: geometry.size.height)
                }
        }
    }
}
