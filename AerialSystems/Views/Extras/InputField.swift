//
//  InputField.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 25/11/2021.
//

import SwiftUI

struct InputField: View {
    
    var placeholder: String
    @Binding var text: String
    var type: InputFieldType
    var icon: String?
    var iconAlignment: HorizontalAlignment
    var iconAction: Action?
    @Environment(\.colorScheme) var colorScheme
    
    init(_ placeholder: String, text: Binding<String>, type: InputFieldType = .text, icon: String? = nil, iconAlignment: HorizontalAlignment = .trailing, iconAction: Action? = {}) {
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.icon = icon
        self.iconAlignment = iconAlignment
        self.iconAction = iconAction
    }
    
    var body: some View {
        HStack {
            if iconAlignment == .leading {
                iconButton
                inputField
            } else {
                inputField
                iconButton
            }
        }.padding(.horizontal, 18)
        .padding(.vertical, 13)
        .foregroundColor(colorScheme == .dark ? Color(.white) : Color(.black).opacity(0.8))
        .background(Color(.systemGray6).opacity(0.8))
        .addBorder(Color(.systemGray5), width: 1, cornerRadius: 6)
    }
    
    @ViewBuilder var inputField: some View {
        if type == .password {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }
    
    @ViewBuilder var iconButton: some View {
        if let icon = icon, let iconAction = iconAction {
            Button(action: iconAction, label: {
                Image(systemName: icon).foregroundColor( Color(.systemGray))
            })
        }
    }
}

struct InputField_Previews: PreviewProvider {
    @State static var text: String = "test"
    static var previews: some View {
        InputField("", text: $text, icon: "eye.slash", iconAction: {
            print("test")
        })
    }
}

typealias Action = () -> Void

enum InputFieldType {
    case text
    case password
}
