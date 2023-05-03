//
//  CardView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI
import AVFoundation

struct LearnView: View {
    @State
    var words: [Word] = []
    
    @State var isAlertPresented = false
    
    var body: some View {
        ZStack {
            /// change the background color
            Color(red: 0.914, green: 0.973, blue: 0.976).ignoresSafeArea()
            
            GeometryReader { geometry in
                
                ZStack {
                    
                    ForEach(words) { word in
                        if word.id > words.maxId - 4 {
                            
                            CardView(word: word, onRemove: {
                                removedUser in
                                
                                if words.count == 1 {
                                    isAlertPresented = true
                                }
                                
                                words.removeAll() {
                                    $0.id == removedUser.id
                                }
                            })
                            .animation(.spring(), value: words)
                            .frame(width: words
                                .cardWidth(in: geometry, userId: word.id), height: 400)
                            .offset(x: 0, y: words.cardOffset(userId: word.id))
                        }
                        
                    }
                }
                .padding(.top, 100)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                .alert("Bölüm bitti 🥳", isPresented: $isAlertPresented) {
                    
                    Button("Tekrarla 🤓", action: {
                        var count = 0
                        for i in WordViewModel.allWords {
                            count += 1
                            
                            words.append(Word(id: count, word: i.word, translation: i.translation, pronunciation: i.pronunciation))
                            
                            if count == 50 {
                                break
                            }
                        }
                    })
                    
                    Button("Yeni Kelimeler 🤯", action: {
                        WordViewModel.allWords.shuffle()
                        
                        var count = 0
                        for i in WordViewModel.allWords {
                            count += 1
                            
                            words.append(Word(id: count, word: i.word, translation: i.translation, pronunciation: i.pronunciation))
                            
                            if count == 50 {
                                break
                            }
                        }
                    })
                }
                
            }.padding()
                .onAppear(perform: {
                    if words.isEmpty {
                        WordViewModel.allWords.shuffle()
                        
                        var count = 0
                        for i in WordViewModel.allWords {
                            count += 1
                            
                            words.append(Word(id: count, word: i.word, translation: i.translation, pronunciation: i.pronunciation))
                            
                            if count == 50 {
                                break
                            }
                        }
                    }
                })
        }
    }
}

extension Array where Element == Word {
    var maxId: Int {
        map { $0.id }.max() ?? 0
    }
    
    func cardOffset(userId: Int) -> Double {
        Double(count - 1 - userId) * 8.0
    }
    
    func cardWidth(in geometry: GeometryProxy, userId: Int) -> Double {
        geometry.size.width - cardOffset(userId: userId)
    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
