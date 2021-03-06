//
//  PlanningHeaderView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI

struct PlanningHeaderView: View {
    
    @StateObject var viewModel: PlanningViewModel
    
    var body: some View {
        VStack (spacing: 0) {
            GeometryReader { geometry in
                HStack (spacing: 0) {
                    ForEach(Array(PlanningTab.allCases.enumerated()), id: \.offset) { index, tab in
                        Button(action: {
                            viewModel.currentTab = tab
                        }, label: {
                            HStack {
                                Image(systemName: "\(index+1).circle.fill").font(SFPro.title_light_25)
                                Text(tab.description).font(SFPro.title_light)
                            }
                            .frame(width: geometry.size.width/4, height: geometry.size.height)
                            .background(viewModel.currentTab == tab ? Color(.systemBlue) : Color(.systemGray5).opacity(0.9))
                            .foregroundColor(viewModel.currentTab == tab ? .white : Color(.systemGray))
                        }).disabled(viewModel.currentMission.started)
                        Divider()
                    }
                }
            }.frame(maxWidth: .infinity).frame(height: 70)
            Divider()
        }
    }
}
