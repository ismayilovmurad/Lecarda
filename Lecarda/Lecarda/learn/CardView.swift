//
//  CardView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

struct CardView: View {
    var flashCard: FlashCard
    
    @Binding var cardColor: Color
    @State var revealed = false
    @State var offset: CGSize = .zero
    
    typealias CardDrag = (_ card: FlashCard, _ direction: DiscardedDirection) -> Void
    
    let dragged: CardDrag
    
    // MARK: This attribute enables the state of a gesture to be stored and read during a gesture to influence the effects that gesture may have on the drawing of the view.
    @GestureState var isLongPressed = false
    
    init(_ card: FlashCard, cardColor: Binding<Color>, onDrag dragged: @escaping CardDrag = {_,_  in }) {
        flashCard = card
        _cardColor = cardColor
        self.dragged = dragged
    }
    
    var body: some View {
        
        let drag = DragGesture()
            .onChanged { offset = $0.translation }
            .onEnded {
                if $0.translation.width < -100 {
                    offset = .init(width: -1000, height: 0)
                    dragged(flashCard, .left)
                } else if $0.translation.width > 100 {
                    offset = .init(width: 1000, height: 0)
                    dragged(flashCard, .right)
                } else {
                    offset = .zero
                }
            }
        
        let longPress = LongPressGesture()
            .updating($isLongPressed) { value, state, transition in
                state = value
            }
            .simultaneously(with: drag)
        
        return ZStack {
            Rectangle()
                .fill(cardColor)
                .frame(width: 320, height: 210)
                .cornerRadius(12)
            VStack {
                Spacer()
                Text(flashCard.card.word!)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                if revealed {
                    Text(flashCard.card.translation!)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
        .shadow(radius: 8)
        .frame(width: 320, height: 210)
        .animation(.spring(), value: offset)
        .offset(offset)
        .gesture(longPress)
        .scaleEffect(isLongPressed ? 1.1 : 1)
        .animation(
            .easeInOut(duration: 0.3),
            value: isLongPressed
        )
        .simultaneousGesture(TapGesture()
            .onEnded {
                withAnimation(.easeIn, {
                    revealed = !revealed
                })
            })
    }
    
    
}

struct CardView_Previews: PreviewProvider {
    @State static var cardColor = Color.red
    
    static var previews: some View {
        let card = FlashCard(
            card: Word(
                word: "Hola", translation: "Hola", pronunciation: "Hello"
            )
        )
        return CardView(card, cardColor: $cardColor)
    }
}
