//
//  FlashCard.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import Foundation

struct FlashCard: Identifiable {
    var card: Word
    let id = UUID()
    var isActive = true
}

extension FlashCard: Equatable {
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        return lhs.card.word == rhs.card.word && lhs.card.translation == rhs.card.translation
    }
}
