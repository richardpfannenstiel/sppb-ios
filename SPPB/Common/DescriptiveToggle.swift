//
//  DescriptiveToggle.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.08.23.
//

import SwiftUI

struct DescriptiveToggle: View {
    
    @Binding var isOn: Bool
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $isOn) {
                Text(title)
                    .rounded()
            }.tint(.blue)
            Text(description)
                .rounded()
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)
                .padding(.trailing, 50)
                .offset(y: -10)
        }
    }
}

struct DescriptiveToggle_Previews: PreviewProvider {
    static var previews: some View {
        DescriptiveToggle(isOn: .constant(true), title: "Test", description: "Description")
    }
}
