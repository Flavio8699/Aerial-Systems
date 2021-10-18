//
//  CustomButton.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI

struct CustomButton: View {
    
    private let label: String
    private let action : () -> Void
    private var color: Color
    
    init(label: String, color: Color = Color(.systemBlue), action: @escaping () -> Void) {
        self.label = label
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(self.label)
                .padding(.horizontal, 45)
                .padding(.vertical, 18)
                .foregroundColor(.white)
                .background(color)
                .font(SFPro.title)
                .cornerRadius(14)
        }
    }
}
