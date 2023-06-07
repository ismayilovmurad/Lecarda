//
//  InitView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 06.04.23.
//

import SwiftUI
import CoreData
import FirebaseFirestore
import FirebaseAuth

struct InitView: View {
    /// viewContext for Core Data
    @Environment(\.managedObjectContext) private var viewContext
    
    /// databaseReference for Firebase
    private var databaseReference = Firestore.firestore().collection("Words")
    
    /// hide or show the Progress and the Start
    @State private var isProgressHidden: Bool = false
    @State private var isStartHidden: Bool = true
    
    /// show an error message
    @State private var isAlertPresented = false
    @State private var errorMessage = "Bir hata oluştu"
    
    /// translation animation
    @State private var revealed = false
    
    @State private var isTryAgainHidden = true
    
    /// call the environment object
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @EnvironmentObject var userAuth: UserAuth
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    /// change the background color
                    Color(red: 0.914, green: 0.973, blue: 0.976).ignoresSafeArea()
                    
                    /// show the Progress while the Database or the Firebase is being loaded
                    ProgressView("Yükleniyor")
                        .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                        .tint(Color(red: 0.325, green: 0.498, blue: 0.906))
                        .bold()
                        .isHidden(isProgressHidden)
                        .alert(errorMessage, isPresented: $isAlertPresented) {
                            Button("Tamam", role: .cancel) {
                                isTryAgainHidden = false
                            }
                        }
                    
                    /// vertical container for the Start and the Image
                    VStack {
                        /// start
                        VStack {
                            Text("Hadi başlayalım")
                                .font(Font.title2.weight(.bold))
                                .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                            
                            if revealed {
                                Text("Let's get started")
                                    .font(Font.title3.weight(.bold))
                                    .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                                    .padding(2)
                            }
                        }
                        .gesture(TapGesture().onEnded({
                            withAnimation(.easeIn, {
                                revealed = !revealed
                            })
                        }))
                        
                        /// image
                        NavigationLink(destination: MainView()) {
                            Image(systemName: "hand.tap.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .padding(44)
                                .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                        }
                    }
                    .isHidden(isStartHidden)
                    
                    /// try again
                    Button("Tekrar dene", action: {
                        isTryAgainHidden = true
                        errorMessage = "Bir hata oluştu"
                        isProgressHidden = false
                        fetchDatabase()
                    })
                    .font(Font.title3.weight(.bold))
                    .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                    .isHidden(isTryAgainHidden)
                }
                
                Text("Çeviriyi görmek için karta dokunun 🤓")
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .bold()
                    .padding(5)
                
                Text("Telaffuzu duymak için karta dokunun ve basılı tutun 🤫")
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .bold()
                    .padding(5)
                
            }.background(Color(red: 0.914, green: 0.973, blue: 0.976))
        }
        .onAppear(perform: {
            fetchDatabase()
        })
    }
    
    func fetchDatabase() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        do {
            let result = try viewContext.fetch(request)
            
            for data in result as! [NSManagedObject] {
                let word = data.value(forKey: "word") as! String
                let translation = data.value(forKey: "translation") as! String
                let pronunciation = data.value(forKey: "pronunciation") as! String
                
                WordViewModel.allWords.append(Word(id: 0, word: word, translation: translation, pronunciation: pronunciation))
            }
            
            if WordViewModel.allWords.isEmpty {
                /// the database is empty, we're about to fetch the data from Firebase, let's check the internet connection
                if networkMonitor.isConnected {
                    /// there's an internet connection, let's fetch the data from Firebase
                    fetchFirebase()
                } else{
                    /// there's no internet connection, let's hide the progress and show the Alert
                    isProgressHidden = true
                    showError(error: ": İnternet bağlantısı yok")
                }
            } else {
                generateRandomWords()
                
                /// the database isn't empty, let's hide the Progress and show the Start
                hideProgress(hide: true)
            }
        } catch {
            /// there's an error while fetching from the database, let's hide the Progress and show the Alert
            isProgressHidden = true
            let errorMessage = error.localizedDescription != "" ? error.localizedDescription : "Veri alınamadı"
            showError(error: ": \(errorMessage)")
        }
    }
    
    func generateRandomWords() {
        while WordViewModel.words.count < 50 {
            let randomNumber = Int.random(in: 0..<WordViewModel.allWords.count)
            
            WordViewModel.words.append(WordViewModel.allWords[randomNumber])
        }
    }
    
    func fetchFirebase() {
        databaseReference.getDocuments(completion: {snapshot, error in
            
            if error == nil {
                
                if snapshot != nil {
                    
                    if !snapshot!.documents.isEmpty {
                        
                        for i in snapshot!.documents {
                            let word = Word(id: 0, word: i.data()["Word"] as! String, translation: i.data()["Translation"] as! String , pronunciation: i.data()["Pronunciation"] as! String)
                            WordViewModel.allWords.append(word)
                        }
                        
                        if !WordViewModel.allWords.isEmpty {
                            /// We got the list from Firebase, let's save it to the database
                            saveDatabase()
                        }else {
                            /// the list is empty, let's hide the Progress and show the Alert
                            isProgressHidden = true
                            showError(error: ": Veri alınamadı")
                        }
                    } else{
                        /// the documents is empty, let's hide the Progress and show the Alert
                        isProgressHidden = true
                        showError(error: ": Veri alınamadı")
                    }
                } else{
                    /// the snapshot is empty, let's hide the Progress and show the Alert
                    isProgressHidden = true
                    showError(error: ": Veri alınamadı")
                }
            } else {
                /// there's an error while fetching from the database, let's hide the Progress and show the Alert
                isProgressHidden = true
                let errorMessage = error!.localizedDescription
                showError(error: ": \(errorMessage)")
            }
        })
    }
    
    func saveDatabase() {
        for i in WordViewModel.allWords {
            let item = Item(context: viewContext)
            item.word = i.word
            item.translation = i.translation
            item.pronunciation = i.pronunciation
            
            do {
                try viewContext.save()
            } catch {
                /// there's an error while saving to the database, let's hide the Progress and show the Alert
                isProgressHidden = true
                let errorMessage = error.localizedDescription != "" ? error.localizedDescription : "Veri kaydedilemedi"
                showError(error: ": \(errorMessage)")
            }
        }
        
        generateRandomWords()
        hideProgress(hide: true)
    }
    
    func hideProgress(hide: Bool) {
        isProgressHidden = hide
        isStartHidden = !hide
    }
    
    func showError(error: String) {
        errorMessage += error
        isAlertPresented = true
    }
}
