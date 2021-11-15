//
//  Camera.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 11/11/2021.
//

import Foundation

struct Camera: Hashable, Codable {
    var name: String
    var image: String
    var lens: String
    var fov: String
    var spectral_bands: String
}
