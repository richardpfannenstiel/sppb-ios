//
//  DynamicSheet.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.08.23.
//

import SwiftUI

struct GlassSheet<SheetContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @ViewBuilder var content: SheetContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                self.content
                    .padding()
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(50)
                    .presentationBackground(.ultraThinMaterial)
                    .preferredColorScheme(.light)
            }
    }
}

extension View {
    func glassSheet<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.modifier(GlassSheet(isPresented: isPresented, content: content))
    }
}
