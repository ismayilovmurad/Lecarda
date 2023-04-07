//
//  MainView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI


struct MainView: View {
    var vm = WordViewModel()
    
    var body: some View {
        TabView {
            LearnView().tabItem({
                VStack {
                    Image(systemName: "book.fill")
                    Text("Cards")
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
                Text("Settings")
            })
        }
        .accentColor(.orange)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
