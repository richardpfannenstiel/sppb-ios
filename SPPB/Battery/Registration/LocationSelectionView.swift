//
//  LocationSelectionView.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 21.08.23.
//

import SwiftUI

struct LocationSelectionView: View {
    
    // MARK: - Constants
    
    private enum Constant {
        static let locationSelectionLabel = "Select Location".localized
    }
    
    // MARK: - State
    
    @Binding var location: Location?
    @State var showingLocationOptions = false
    
    var body: some View {
        VStack {
            Button(action: animateOptions) {
                HStack {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(showingLocationOptions ? 90 : 0))
                    Text(location?.label ?? Constant.locationSelectionLabel)
                        .rounded()
                    Spacer()
                }.padding(.horizontal)
                .frame(width: width - 50)
                .foregroundColor(location == nil ? .textField : .primary)
            }.buttonStyle(FlatSolidButton())
            
            if showingLocationOptions {
                ForEach(Location.allCases, id: \.rawValue) { location in
                    if location != self.location {
                        Button(action: { set(location) }) {
                            Text(location.label)
                                .rounded()
                                .frame(width: width - 50)
                        }.buttonStyle(FlatSolidButton())
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    }
                }
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func animateOptions() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8)) {
            showingLocationOptions.toggle()
        }
    }
    
    private func set(_ location: Location) {
        withAnimation {
            showingLocationOptions.toggle()
            self.location = location
        }
    }
}

struct LocationSelectionView_Previews: PreviewProvider {
    static var location: Location? = nil
    
    static var previews: some View {
        LocationSelectionView(location: .init(get: {
            location
        }, set: { newLocation in
            location = newLocation
        })).background(BackgroundView())
    }
}
