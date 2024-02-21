//
//  DynamicSheet.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 11.08.23.
//

import SwiftUI

struct DynamicSheet<SheetContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @ViewBuilder var content: SheetContent
    
    @State private var sheetHeight: CGFloat = 300
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                sheetHeight = content.height
            }
            .sheet(isPresented: $isPresented) {
                self.content
                    .padding()
                    .overlay {
                        GeometryReader { geometry in
                            Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                        }
                    }
                    .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                        DispatchQueue.main.async {
                            sheetHeight = newHeight
                        }
                    }
                    .presentationDetents([.height(sheetHeight)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(50)
                    .presentationBackground(.ultraThinMaterial)
                    .preferredColorScheme(.light)
            }
    }
}

extension View {
    func dynamicSheet<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.modifier(DynamicSheet(isPresented: isPresented, content: content))
    }
}
