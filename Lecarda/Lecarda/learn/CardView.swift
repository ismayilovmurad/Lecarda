//
//  CardView2.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 28.04.23.
//

import SwiftUI
import AVFoundation

struct CardView: View {
    @State
    private var translation: CGSize = .zero
    private var word: Word
    private var onRemove: (_ user: Word) -> Void
    private var threshold: CGFloat = 0.5
    
    /// translation animation
    @State private var revealed = false
    
    /// this attribute enables the state of a gesture to be stored and read during a gesture to influence the effects that gesture may have on the drawing of the view.
    @GestureState var isLongPressed = false
    
    let synthesizer = AVSpeechSynthesizer()
    
    init(word: Word, onRemove: @escaping (_ word: Word)  -> Void) {
        self.word = word
        self.onRemove = onRemove
    }
    
    var body: some View {
        let longPress = LongPressGesture()
            .updating($isLongPressed) { value, state, transition in
                state = value
            }
            .onEnded({_ in
                let utterance = AVSpeechUtterance(string: word.word)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        utterance.rate = 0.52
                        self.synthesizer.speak(utterance)
            })
        
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(.blue)
                    .cornerRadius(10)
                    .frame(width: geometry.size.width - 20,
                           height: geometry.size.height * 0.65)
                
                VStack {
                    Text("\(word.word)")
                        .lineLimit(2, reservesSpace: false)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("\(word.pronunciation)")
                        .lineLimit(2, reservesSpace: false)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    if revealed {
                        Text("\(word.translation)")
                            .lineLimit(2, reservesSpace: false)
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 15)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .animation(.spring(), value: translation)
            .offset(x: translation.width, y: 0)
            .rotationEffect(
                .degrees(
                    Double(translation.width/geometry.size.width)*20),
                anchor: .bottom)
            .gesture(DragGesture()
                .onChanged {
                    translation = $0.translation
                }.onEnded{
                    if $0.percentage(in: geometry) > self.threshold {
                        onRemove(word)
                    } else {
                        translation = .zero
                    }
                }
            )
            .simultaneousGesture(TapGesture()
                .onEnded {
                    withAnimation(.easeIn, {
                        revealed = !revealed
                    })
                })
            .simultaneousGesture(longPress)
            .scaleEffect(isLongPressed ? 1.1 : 1)
            .animation(
                .easeInOut(duration: 0.3),
                value: isLongPressed
            )
        }
    }
}

extension DragGesture.Value {
    func percentage(in geometry: GeometryProxy) -> Double {
        abs(translation.width / geometry.size.width)
    }
}
