//
//  LearningStore.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import Foundation

class LearningStore: ObservableObject {
    
    @Published var deck: FlashDeck
    @Published var card: FlashCard?
    
    init(deck: [Word]) {
        self.deck = FlashDeck(from: deck)
        self.card = getNextCard()
    }
    
    func getNextCard() -> FlashCard? {
        guard let card = deck.cards.last else {
            return nil
        }
        
        self.card = card
        deck.cards.removeLast()
        return self.card
    }
}
