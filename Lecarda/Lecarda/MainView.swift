//
//  MainView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        TabView {
            LearnView().tabItem({
                VStack {
                    Image(systemName: "book.fill")
                    Text("Kartlar")
                }
            })
            
            TestView().tabItem({
                VStack {
                    Image(systemName: "questionmark.diamond.fill")
                    Text("Test")
                }
            })
            
            SettingsView().tabItem({
                Image(systemName: "gear")
                Text("Ayarlar")
            })
        }
        .onAppear{
            WordViewModel.words.shuffle()
            
            /// change the background color of the TabBar
            UITabBar.appearance().backgroundColor = UIColor(Color(red: 0.914, green: 0.973, blue: 0.976))
            
            /// change the color of the unselected tab
            UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 0.537, green: 0.769, blue: 0.882))
        }
        .accentColor(Color(red: 0.325, green: 0.498, blue: 0.906))
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
