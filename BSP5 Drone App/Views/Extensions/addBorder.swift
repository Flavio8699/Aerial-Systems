//
//  addBorder.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 18/10/2021.
//

import SwiftUI

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 0, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}
