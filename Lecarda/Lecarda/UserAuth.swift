//
//  UserAuth.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 20.05.23.
//

import Foundation

class UserAuth: ObservableObject {
    @Published var isLoggedin: Bool = false
    
    func login() {
        self.isLoggedin = true
    }
    
    func logout() {
        self.isLoggedin = false
    }
}
