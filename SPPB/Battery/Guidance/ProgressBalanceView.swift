//
//  ProgressBalanceView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 07.08.23.
//

import SwiftUI

struct ProgressBalanceView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let balanceTestLabel = "Balance Tests".localized
        static let sideBySideLabel = "Side-by-Side Stand".localized
        static let semiTandemLabel = "Semi-Tandem Stand".localized
        static let tandemLabel = "Tandem Stand".localized
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
                    if model.showingIndividualBalanceTests {
                        ZStack {
                            Canvas { context, size in
                                let firstCircle = context.resolveSymbol(id: 0)!
                                let secondCircle = context.resolveSymbol(id: 1)!
                                let thirdCircle = context.resolveSymbol(id: 2)!
                                context.addFilter(.alphaThreshold(min: 0.2, color: .white))
                                context.addFilter(.blur(radius: 15))
                                context.drawLayer { context2 in
                                    context2.draw(firstCircle, at: .init(x: size.width / 2,
                                                                         y: size.height / 2))
                                    context2.draw(secondCircle, at: .init(x: size.width / 2,
                                                                          y: size.height / 2))
                                    context2.draw(thirdCircle, at: .init(x: size.width / 2,
                                                                          y: size.height / 2))
                                }
                            } symbols: {
                                HStack {
                                    Circle()
                                        .foregroundColor(.white)
                                        .frame(width: model.showingIndividualBalanceTestsExpanded ? 30 : 35)
                                        .padding(.leading, model.showingIndividualBalanceTestsExpanded ? 10 : 7.5)
                                    Spacer()
                                }.tag(0)
                                    .offset(x: 15)
                                HStack {
                                    Circle()
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                        .padding(.leading, 10)
                                    Spacer()
                                }.tag(1)
                                    .offset(x: 15, y: model.showingIndividualBalanceTestsExpanded ? 75 : 0)
                                HStack {
                                    Circle()
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                        .padding(.leading, 10)
                                    Spacer()
                                }.tag(2)
                                    .offset(x: 15, y: model.showingIndividualBalanceTestsExpanded ? -75 : 0)
                            }.padding(.horizontal, -15)
                            
                            ZStack {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(.clear)
                                            .frame(width: 40)
                                            .padding(.leading, 5)
                                        Circle()
                                            .foregroundColor(model.semiTandemBulletColor)
                                            .frame(width: model.semiTandemFinished ? 30 : 0)
                                            .padding(.leading, -5)
                                    }
                                    HStack {
                                        Spacer()
                                        Text(Constant.semiTandemLabel)
                                            .rounded()
                                        Spacer()
                                    }.padding()
                                        .background(Color.white)
                                        .cornerRadius(20)
                                }
                                HStack {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(.clear)
                                            .frame(width: 40)
                                            .padding(.leading, 5)
                                        Circle()
                                            .foregroundColor(model.tandemBulletColor)
                                            .frame(width: model.tandemFinished ? 30 : 0)
                                            .padding(.leading, -5)
                                    }
                                    HStack {
                                        Spacer()
                                        Text(Constant.tandemLabel)
                                            .rounded()
                                        Spacer()
                                    }.padding()
                                        .background(Color.white)
                                        .cornerRadius(20)
                                }.offset(y: model.showingIndividualBalanceTestsExpanded ? 75 : 0)
                                HStack {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(.clear)
                                            .frame(width: 40)
                                            .padding(.leading, 5)
                                        Circle()
                                            .foregroundColor(model.sideBySideBulletColor)
                                            .frame(width: model.sideBySideFinished ? 30 : 0)
                                            .padding(.leading, -5)
                                    }
                                    HStack {
                                        Spacer()
                                        Text(Constant.sideBySideLabel)
                                            .rounded()
                                        Spacer()
                                    }.padding()
                                        .background(Color.white)
                                        .cornerRadius(20)
                                }.offset(y: model.showingIndividualBalanceTestsExpanded ? -75 : 0)
                            }.padding(.leading, 5)
                        }
                    } else {
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
                    }
                    Spacer()
                    HStack {
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 50)
                        HStack {
                            Spacer()
                            Text(Constant.gaitSpeedTestLabel)
                                .rounded()
                            Spacer()
                        }.padding()
                        .background(Color.white)
                        .cornerRadius(20)
                    }.matchedGeometryEffect(id: Constant.gaitSpeedTestLabel, in: namespace)
                    HStack {
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 50)
                        HStack {
                            Spacer()
                            Text(Constant.chairStandTestLabel)
                                .rounded()
                            Spacer()
                        }.padding()
                        .background(Color.white)
                        .cornerRadius(20)
                    }.matchedGeometryEffect(id: Constant.chairStandTestLabel, in: namespace)
                }
            }.padding(.horizontal)
        }
    }
}
