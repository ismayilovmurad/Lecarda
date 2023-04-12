//
//  DeckView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

// MARK: When using observed objects there are four key things we need to work with:

// MARK: ObservableObject protocol
// It's used with some sort of class that can store data.
// MARK: @ObservableObject property wrapper
// It's used inside a view to store an observable object instance.
// MARK: @Published property wrapper
// It's added to any properties inside an observed object that should cause views to update when they change.
// MARK: @StateObject property wrapper
// It is really important that you use @ObservedObject only with views that were passed in from elsewhere. You should not use this property wrapper to create the initial instance of an observable object – that’s what @StateObject is for. Do not use @ObservedObject to create instances of your object. If that’s what you want to do, use @StateObject instead.

enum DiscardedDirection {
    case left
    case right
}

struct DeckView: View {
    @ObservedObject var deck: FlashDeck
        
    init(deck: FlashDeck) {
        self.deck = deck
    }
    
    var body: some View {
        ZStack {
            Text("Bölüm sona erdi, lütfen daha sonra tekrar dene.")
                .font(Font.title.weight(.bold))
                .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                .padding()
            ForEach(deck.cards.filter { $0.isActive }) { card in
                getCardView(for: card)
            }
        }
    }
    
    func getCardView(for card: FlashCard) -> CardView {
        let activeCards = deck.cards.filter { $0.isActive == true }
        
        if let lastCard = activeCards.last {
            if lastCard == card {
                return createCardView(for: card)
            }
        }
        
        let view = createCardView(for: card)
        
        return view
    }
    
    func createCardView(for card: FlashCard) -> CardView {
        let view = CardView(card, onDrag: { card, direction in
            if direction == .left {
                // TODO: left it is
            }
        })
        
        return view
    }
}

struct DeckView_Previews: PreviewProvider {
    static var previews: some View {
        DeckView(deck: FlashDeck(from: WordViewModel.words))
    }
}
