//
//  PlanningViewModel.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 08/10/2021.
//

import SwiftUI
import MapKit

class PlanningViewModel: ObservableObject {
    
    @Published var currentTab: PlanningTab = .zone
    @Published var currentMission: Mission = Mission()
    @Published var zoomIn: Bool = false
    
    var selectedArea: Int {
        regionArea(locations: self.currentMission.locations.map { $0.coordinates.toLocation() })
    }
    
    func loadMission(mission: Mission) {
        self.currentMission = mission
        self.zoomIn = true
        
        if self.currentMission.started {
            self.currentTab = .summary
        }
    }
    
    func radians(degrees: Double) -> Double {
        return degrees * Double.pi / 180;
    }

    func regionArea(locations: [CLLocationCoordinate2D]) -> Int {
        let kEarthRadius = 6378137.0
        
        guard locations.count > 2 else { return 0 }
        var area = 0.0
        
        for i in 0..<locations.count {
            let p1 = locations[i > 0 ? i - 1 : locations.count - 1]
            let p2 = locations[i]

            area += radians(degrees: p2.longitude - p1.longitude) * (2 + sin(radians(degrees: p1.latitude)) + sin(radians(degrees: p2.latitude)) )
        }

        area = -(area * kEarthRadius * kEarthRadius / 2);

        return Int(max(area, -area).rounded())
    }
    
}

