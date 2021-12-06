//
//  Index.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 14/10/2021.
//

import Foundation

struct Index: Identifiable, Hashable, Equatable, Decodable {
    var id: UUID? = UUID()
    var title: String
    var subtitle: String
    var description: String
}
