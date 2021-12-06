//
//  GeoPoint.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 04/11/2021.
//

import Foundation
import MapKit
import FirebaseFirestore

extension GeoPoint {
    func toLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
