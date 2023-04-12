//
//  CardView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

struct LearnView: View {
    
    @StateObject var learningStore = LearningStore(deck: WordViewModel.words)
    
    var body: some View {
        ZStack {
            /// change the background color
            Color(red: 0.914, green: 0.973, blue: 0.976).ignoresSafeArea()
            
            VStack {
                Spacer()
                DeckView(deck: learningStore.deck)
                Spacer()
            }
        }
    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
