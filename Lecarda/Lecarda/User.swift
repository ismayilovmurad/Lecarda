//
//  User.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 05.06.23.
//

import Foundation

struct User: Hashable {
    var email: String
    var score: Int
    var place: Int = 0
    
    mutating func updatePlace(newPlace: Int) {
        place = newPlace
    }
}
