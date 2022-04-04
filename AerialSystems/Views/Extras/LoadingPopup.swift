//
//  LoadingPopup.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 08/03/2022.
//

import SwiftUI

struct LoadingPopup: View {
    
    let message: String
    let duration: CGFloat
    @State private var isLoading = false
     
    var body: some View {
        Text(message).font(SFPro.title_light)
        ZStack(alignment: .leading) {
            Rectangle().frame(maxWidth: .infinity, maxHeight: 10)
                .opacity(0.3)
                .foregroundColor(Color(UIColor.systemTeal))
            
            Rectangle().frame(maxWidth: .infinity, maxHeight: 10)
                .foregroundColor(Color(UIColor.systemBlue))
                .animation(.linear(duration: duration-0.2))
        }.cornerRadius(45.0)
    }
}
