//
//  IndexInfoSheetView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 19/11/2021.
//

import SwiftUI

struct IndexInfoSheetView: View {
    
    var index: Index
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text(index.title)
                Text(index.subtitle)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Test title")
            .toolbar {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
