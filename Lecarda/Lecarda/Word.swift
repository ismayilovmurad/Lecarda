//
//  Word.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 06.04.23.
//

import FirebaseFirestoreSwift

struct Word: Codable {
    @DocumentID var id: String?
    var word: String?
    var translation: String?
    var pronunciation: String?
}
