//
//  PlanningView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI

struct PlanningView: View {
    
    @StateObject var viewModel = PlanningViewModel()
    
    var body: some View {
        switch viewModel.currentTab {
        case .zone:
            ZoneView(viewModel: viewModel)
        case .monitoring:
            MonitoringView(viewModel: viewModel)
        case .drones_and_cameras:
            DronesCamerasView(viewModel: viewModel)
        case .summary:
            VStack (spacing: 0) {
                PlanningHeaderView(viewModel: viewModel)
                Text("Summary")
                Spacer()
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
