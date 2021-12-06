//
//  User.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 04/11/2021.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var map: String
    var missions: [Mission]?
    
    func getID() -> String {
        return String(describing: self.id ?? "")
    }
    
    func getMissions() -> [Mission] {
        return self.missions ?? []
    }
}

