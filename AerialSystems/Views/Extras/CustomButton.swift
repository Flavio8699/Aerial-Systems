//
//  CustomButton.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI

struct CustomButton: View {
    
    private let label: String
    private let action: () -> Void
    private var color: Color
    var loading: Bool
    private var entireWidth: Bool
    @Environment(\.colorScheme) var colorScheme
    
    init(label: String, color: Color = Color(.systemBlue), loading: Bool = false, entireWidth: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.color = color
        self.loading = loading
        self.entireWidth = entireWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if entireWidth {
                    Spacer(minLength: 0)
                }
                if loading {
                    ProgressView()
                } else {
                    Text(label).foregroundColor(color == Color(.systemBlue) || color == Color(.systemRed) ? .white : Color(UIColor.systemBackground))
                }
                if entireWidth {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .foregroundColor(.white)
            .background(color)
            .font(SFPro.title_regular)
            .cornerRadius(14)
        }
    }
}
