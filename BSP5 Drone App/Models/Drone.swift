//
//  Drone.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 11/11/2021.
//

import Foundation

struct Drone: Hashable, Codable {
    var name: String
    var image: String
    var flight_time: Int
    var hovering_accuracy: String
}
