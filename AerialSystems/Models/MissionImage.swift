//
//  MissionImage.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 19/11/2021.
//

import Foundation

struct MissionImage: Hashable {
    var name: String
    var availableIndices: [Index]
    var url: URL
}
