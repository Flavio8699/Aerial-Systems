//
//  PlanningTab_ZoneView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI
import MapKit

struct ZoneView: View {
    
    let map = MKMapView()
    @StateObject var viewModel: PlanningViewModel
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        ZStack (alignment: .bottom) {
            MapView(map: map, locations: $viewModel.currentMission.locations, mapType: $session.map, zoomIn: $viewModel.zoomIn).onAppear {
                map.fitAll()
            }
            HStack (alignment: .bottom) {
                HStack {
                    Text("Toral area :").bold()
                    Text("\(viewModel.selectedArea)m²")
                }
                .padding(.vertical, 16)
                .padding(.horizontal)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(5)
                Spacer()
                CustomButton(label: "Next step", action: {
                    viewModel.currentTab = .monitoring
                })
            }.padding(20)
        }
    }
}
