//
//  PlanningTab_ZoneView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI

struct ZoneView: View {
    
    @StateObject var viewModel: PlanningViewModel
    
    var body: some View {
        MapView(locations: $viewModel.locations)
        VStack (spacing: 0) {
            PlanningHeaderView(viewModel: viewModel)
            Spacer()
            HStack (alignment: .bottom) {
                HStack {
                    Text("Toral area :").font(SFPro.body_bold)
                    Text("\(viewModel.selectedArea)m²").font(SFPro.body)
                }
                .padding()
                .background(.white)
                .cornerRadius(5)
                .padding()
                Spacer()
                CustomButton(label: "Next step", action: {
                    /*withAnimation(.linear) {
                        viewModel.currentTab = .monitoring
                    }*/
                    self.viewModel.locations.append(.init(latitude: 49.50107619428897, longitude: 5.9400545040158725))
                }).padding()
            }
        }
    }
}
