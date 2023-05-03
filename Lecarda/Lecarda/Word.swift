//
//  Word.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 06.04.23.
//

struct Word: Codable, Identifiable, Equatable {
    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int
    var word: String
    var translation: String
    var pronunciation: String
}
