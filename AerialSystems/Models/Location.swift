//
//  Location.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 15/11/2021.
//

import Foundation
import FirebaseFirestore

struct Location: Codable {
    var id: Int
    var coordinates: GeoPoint
}

func getCornerLocations(locations: [Location]) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
    var top = CGFloat(-Int.max)
    var right = CGFloat(-Int.max)
    var left = CGFloat(Int.max)
    var bottom = CGFloat(Int.max)
    
    for location in locations {
        if abs(location.coordinates.longitude) > right {
            right = location.coordinates.longitude
        }
        if abs(location.coordinates.longitude) < left {
            left = location.coordinates.longitude
        }
        if abs(location.coordinates.latitude) < bottom {
            bottom = location.coordinates.latitude
        }
        if abs(location.coordinates.latitude) > top {
            top = location.coordinates.latitude
        }
    }
    
    return (top, right, bottom, left)
}
