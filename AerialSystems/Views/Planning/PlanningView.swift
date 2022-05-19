//
//  PlanningView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI
import MapKit

struct PlanningView: View {
    
    @State var manageMissions: Bool = false
    @StateObject var viewModel = PlanningViewModel()
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var popupHandler: PopupHandler
    
    var body: some View {
        VStack (spacing: 0) {
            PlanningHeaderView(viewModel: viewModel)
            switch viewModel.currentTab {
                case .zone:
                    ZoneView(viewModel: viewModel)
                case .monitoring:
                    MonitoringView(viewModel: viewModel)
                case .drones_and_cameras:
                    DronesCamerasView(viewModel: viewModel)
                case .summary:
                    SummaryView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $manageMissions) {
            if let user = session.user {
                NavigationView {
                    VStack (spacing: 0) {
                        if let missions = user.getMissions(), missions.count > 0 {
                            List {
                                ForEach (missions, id: \.id) { mission in
                                    HStack {
                                        VStack (alignment: .leading) {
                                            Text(mission.name)
                                            Text("Last save: \(mission.dateString)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                        }
                                        Spacer()
                                        Button(action: {
                                            viewModel.loadMission(mission: mission)
                                            manageMissions = false
                                        }, label: {
                                            Text("Load mission")
                                        })
                                    }
                                }.onDelete { indexSet in
                                    if indexSet.count > 0, missions.count >= indexSet.count {
                                        manageMissions = false
                                        let index = indexSet.first!
                                        let mission = missions[index]
                                        popupHandler.currentPopup = .deleteMission(action: {
                                            mission.delete { result in
                                                switch result {
                                                case .success():
                                                    popupHandler.currentPopup = .success(message: "The mission was deleted successfully!", button: "Ok", action: popupHandler.close)
                                                    viewModel.loadMission(mission: Mission())
                                                case .failure(let error):
                                                    popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                        } else {
                            Text("No missions found.")
                        }
                    }
                    .navigationBarTitle("Manage mission", displayMode: .inline)
                    .navigationBarItems(trailing:
                        Button(action: {
                            manageMissions = false
                        }, label: {
                            Text("Close")
                        })
                    )
                }
            }
        }
        .navigationTitle("Planning: \(viewModel.currentMission.name)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    manageMissions = true
                }, label: {
                    HStack {
                        Image(systemName: "cloud")
                        Text("Manage mission")
                    }
                })
            }
        }
    }
}

enum PlanningTab: Hashable, CustomStringConvertible, CaseIterable {
    case zone
    case monitoring
    case drones_and_cameras
    case summary
    
    var description: String {
        switch self {
            case .zone: return "Zone to scan"
            case .monitoring: return "Monitoring"
            case .drones_and_cameras: return "Drones and cameras"
            case .summary: return "Summary"
        }
    }
}
