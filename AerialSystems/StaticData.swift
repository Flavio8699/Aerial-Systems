//
//  StaticData.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 19/11/2021.
//

import Foundation

class StaticData: ObservableObject {
    
    var activites = [Activity]()
    var cameras = [Camera]()
    var drones = [Drone]()
    var indices = [Index]()
    
    init() {
        self.activites = loadJson("activities.json")
        self.cameras = loadJson("cameras.json")
        self.drones = loadJson("drones.json")
        self.indices = loadJson("indices.json")
    }
}
