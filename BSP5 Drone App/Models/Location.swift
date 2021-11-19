//
//  Location.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 15/11/2021.
//

import Foundation
import FirebaseFirestore

struct Location: Codable {
    var id: Int
    var coordinates: GeoPoint
}
