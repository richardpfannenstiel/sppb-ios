//
//  DynamicSheet.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.08.23.
//

import SwiftUI

struct SolidSheet<SheetContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @ViewBuilder var content: SheetContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                self.content
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(50)
                    .preferredColorScheme(.light)
            }
    }
}

extension View {
    func solidSheet<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.modifier(SolidSheet(isPresented: isPresented, content: content))
    }
}
