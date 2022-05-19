//
//  SessionStore.swift
//  Aerial Systems
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
    @Published var currentTab: Tab = .planning
    @Published var showSettings: Bool = false
    @Published var loggedIn: Bool = UserDefaults.standard.bool(forKey: "loggedIn")
    @Published var performingMission: Mission? {
        didSet {
            self.currentTab = .live
        }
    }
    @Published var fullScreen: Bool = false
    @Published var loadingMissions: Bool = true
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
                    self.loadingMissions = false
                    return
                }
                self.user!.missions = missions.compactMap { queryDocumentSnapshot -> Mission? in
                    let missions = try? queryDocumentSnapshot.data(as: Mission.self)
                    self.loadingMissions = false
                    return missions
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
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func register(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Auth.auth().createUser(withEmail: email, password: password) { (res, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let res = res {
                        self.db.collection("users").document(res.user.uid).setData(["fullname": name, "map": "satellite"])
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func passwordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

