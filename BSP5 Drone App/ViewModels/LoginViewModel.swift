//
//  LoginViewModel.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 19/10/2021.
//

import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordVisible: Bool = false
    @Published var error: String = ""
    @Published var loading: Bool = false
 
    func login() {
        self.loading = true
        Auth.auth().signIn(withEmail: self.email, password: self.password) { (res, error) in
            if error != nil {
                self.error = error!.localizedDescription
            } else {
                UserDefaults.standard.set(true, forKey: "loggedIn")
                NotificationCenter.default.post(name: NSNotification.Name("loggedIn"), object: nil)
            }
            self.loading = false
        }
    }
}
