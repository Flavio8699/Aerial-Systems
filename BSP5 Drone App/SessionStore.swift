//
//  SessionStore.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 22/10/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseDatabase
import MapKit

class SessionStore: ObservableObject {
    
    @Published var user: User?
    var map: MKMapType {
        set {
            self.setMapType(map: newValue)
        }
        get {
            return self.getMapType()
        }
    }
    let availableMaps: [String: MKMapType] = ["standard": .standard, "satellite": .satellite]
    let db = Firestore.firestore()

    func listen() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.db.collection("users").document(user.uid).addSnapshotListener { documentSnapshot, error in
                    guard let user = documentSnapshot, user.exists else {
                        print("User does not exist")
                        return
                    }
                    do {
                        self.user = try user.data(as: User.self)
                        self.loadMissions()
                    } catch {
                        print("Error while decoding user")
                    }
                }
            } else {
                self.user = nil
            }
        }
    }
    
    func loadMissions() {
        if let user = self.user {
            self.db.collection("users/\(user.getID())/missions").addSnapshotListener { documentSnapshot, error in
                guard let missions = documentSnapshot?.documents else {
                    print("No missions found")
                    return
                }
                self.user!.missions = missions.compactMap { queryDocumentSnapshot -> Mission? in
                    return try? queryDocumentSnapshot.data(as: Mission.self)
                }
            }
        }
    }
    
    func getMapType() -> MKMapType {
        if let user = self.user {
            return self.availableMaps[user.map] ?? .satellite
        }
        return .satellite
    }
    
    func setMapType(map: MKMapType) {
        if let user = self.user {
            var value = ""
            switch map {
                case .standard:
                    value = "standard"
                default:
                    value = "satellite"
            }
            self.db.collection("users").document(user.getID()).updateData(["map": value])
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Auth.auth().signIn(withEmail: email, password: password) { (res, error) in
                if error != nil {
                    completion(.failure(error!))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func register(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Auth.auth().createUser(withEmail: email, password: password) { (res, error) in
                if error != nil {
                    completion(.failure(error!))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func passwordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                completion(.failure(error!))
            } else {
                completion(.success(()))
            }
        }
    }
}

