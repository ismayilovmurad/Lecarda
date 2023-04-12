//
//  FlashDeck.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import Foundation

/// the ObservableObject conformance allows instances of this class to be used inside views, so that when important changes happen the view will reload.
class FlashDeck: ObservableObject {
    // the @Published property wrapper tells SwiftUI that changes to score should trigger view reloads.
    @Published var cards: [FlashCard]
    
    init(from words: [Word]) {
        cards = words.map {
            FlashCard(card: Word(word: $0.word!, translation: $0.translation!, pronunciation: $0.pronunciation!))
        }
    }
}
