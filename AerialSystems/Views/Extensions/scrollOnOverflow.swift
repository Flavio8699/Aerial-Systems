//
//  scrollOnOverflow.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 18/10/2021.
//  Source (modified): https://stackoverflow.com/questions/62463142/swiftui-make-scrollview-scrollable-only-if-it-exceeds-the-height-of-the-screen
//

import SwiftUI

struct OverflowContentViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false
    @State private var height: CGFloat = 0
    @State private var heightCalculated: Bool = false
    
    var spacing: CGFloat
    var padding: Edge.Set
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            VStack (spacing: spacing) {
                content
            }
            .overlay(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        self.height = min(geometry.size.height, proxy.size.height)+spacing
                        self.heightCalculated = true
                        self.contentOverflow = proxy.size.height > geometry.size.height
                    }
                }
            )
            .padding(padding)
            .wrappedInScrollView(when: contentOverflow)
        }.frame(maxHeight: heightCalculated ? height : 9999)
    }
}

extension View {
    @ViewBuilder
    func wrappedInScrollView(when condition: Bool) -> some View {
        if condition {
            ScrollView {
                self
            }
        } else {
            self
        }
    }
}

extension View {
    func scrollOnOverflow(spacing: CGFloat = 10, padding: Edge.Set = [.horizontal, .bottom]) -> some View {
        modifier(OverflowContentViewModifier(spacing: spacing, padding: padding))
    }
}
