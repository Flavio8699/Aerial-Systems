//
//  RegisterViewModel.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 28/10/2021.
//

import Foundation
import FirebaseAuth

class RegisterViewModel: ObservableObject {
    
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordVisible: Bool = false
    @Published var loading: Bool = false

}
