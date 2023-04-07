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
        VStack {
            Spacer()
            DeckView(deck: learningStore.deck)
            Spacer()
        }
    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
