//
//  Mission.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 04/11/2021.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Mission: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var locations: [Location]
    var activities: [String]
    var indices: [String]
    var drone: String
    var camera: String
    var timestamp: Date
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy 'at' HH:mm"
        return formatter.string(from: timestamp)
    }
    
    init(name: String = "Unnamed", locations: [Location] = [], activities: [String] = [], indices: [String] = [], drone: String = "DJI Matrice 210", camera: String = "Zenmuse XT", timestamp: Date = .now) {
        self.name = name
        self.locations = locations
        self.activities = activities
        self.indices = indices
        self.drone = drone
        self.camera = camera
        self.timestamp = timestamp
    }
    
    static func == (lhs: Mission, rhs: Mission) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Location: Codable {
    var id: Int
    var coordinates: GeoPoint
}

extension Mission {
    func updateOrAdd() {
        if let documentID = self.id {
            self.update(id: documentID)
        } else {
            self.create()
        }
    }
    
    func delete() {
        if let documentID = self.id, let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/missions").document(documentID).delete { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    private func update(id: String) {
        if let user = Auth.auth().currentUser {
            do {
                let _ = try Firestore.firestore().collection("users/\(user.uid)/missions").document(id).setData(from: self)
            }
            catch {
                print(error)
            }
        }
    }
    
    private func create() {
        if let user = Auth.auth().currentUser {
            do {
                let _ = try Firestore.firestore().collection("users/\(user.uid)/missions").addDocument(from: self)
            }
            catch {
                print(error)
            }
        }
    }
}



func sortAnnotations(locations: [Location]) -> [Location] {
    if locations.count > 0 {
        var locationsCopy = locations
        // Get first location and add it to the result list
        let first = locationsCopy.remove(at: 0)
        var result: [Location] = [first]
        
        // Loop n times for n locations
        for _ in 0..<locations.count {
            // Define closestIndex and closestDistance as neutral values
            var closestIndex = -1
            var closestDistance: CGFloat = .infinity
            
            // Loop over all the remaining locations in the list (does not contain the current location)
            for (currentIndex, currentLocation) in locationsCopy.enumerated() {
                // Calculate distance between the last location in the list and the current location
                let distance = distanceInKmBetweenEarthCoordinates(point1: result.last!.coordinates, point2: currentLocation.coordinates)
                
                // If the current location is the closest to the last location in the list, update the values
                if closestDistance > distance {
                    closestDistance = distance
                    closestIndex = currentIndex
                }
            }
            
            // If a new closest location was found, append it to the result and remove from the list
            if closestIndex != -1 {
                result.append(locationsCopy[closestIndex])
                locationsCopy.remove(at: closestIndex)
            }
        }
        return result
    }
    return []
}

func degreesToRadians(degrees: CGFloat) -> CGFloat {
    return degrees * CGFloat.pi / 180;
}

func distanceInKmBetweenEarthCoordinates(point1: GeoPoint, point2: GeoPoint) -> CGFloat {
    var earthRadiusKm: CGFloat = 6371;

    var dLat = degreesToRadians(degrees: point2.latitude-point1.latitude);
    var dLon = degreesToRadians(degrees: point2.longitude-point1.longitude);

    let lat1 = degreesToRadians(degrees: point1.latitude);
    let lat2 = degreesToRadians(degrees: point2.latitude);

    var a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2);
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    return earthRadiusKm * c;
}
