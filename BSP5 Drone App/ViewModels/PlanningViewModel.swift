//
//  PlanningViewModel.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 08/10/2021.
//

import SwiftUI
import Combine
import MapKit

class PlanningViewModel: ObservableObject {
    
    @Published var currentTab: PlanningTab = .drones_and_cameras
    
    @Published var locations: [CLLocationCoordinate2D] = [.init(latitude: 49.50631564241318, longitude: 5.941884408650027), .init(latitude: 49.50525665878009, longitude: 5.95445860403537), .init(latitude: 49.50039759347766, longitude: 5.954718385451161)]
    
    var selectedArea: Int {
        regionArea(locations: self.locations)
    }
    
    var indices = [Index]()
    @Published var selectedIndices = [Index]()
    
    var activites = [Activity]()
    @Published var selectedActivites = [Activity]()
    
    init() {
        self.indices = loadJson("indices.json")
        self.activites = loadJson("activities.json")
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
