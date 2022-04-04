//
//  DJIAnnotation.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 30/03/2022.
//

import UIKit
import MapKit

class CustomAnnotation: MKPointAnnotation {

    var identifier = ""
    
    fileprivate var _heading: Double = 0.0
    public var heading: Double {
        get {
            return _heading
        }
        set {
            _heading = newValue
        }
    }
    
    convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    convenience init(coordinates: CLLocationCoordinate2D, heading: Double) {
        self.init()
        self.coordinate = coordinates
        _heading = heading
    }
    
}
