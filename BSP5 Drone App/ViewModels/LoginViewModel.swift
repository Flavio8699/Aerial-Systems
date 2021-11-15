//
//  LoginViewModel.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 19/10/2021.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordVisible: Bool = false
    @Published var loading: Bool = false
    
}
