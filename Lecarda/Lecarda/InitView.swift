//
//  InitView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 06.04.23.
//

import SwiftUI
import CoreData
import FirebaseFirestore

struct InitView: View {
    /// viewContext for Core Data
    @Environment(\.managedObjectContext) private var viewContext
    
    /// databaseReference for Firebase
    private var databaseReference = Firestore.firestore().collection("Words")
    
    @State private var isProgressHidden: Bool = false
    @State private var isStartHidden: Bool = true
    
    @State private var isAlertPresented = false
    @State private var errorMessage = "An error ocurred"
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: MainView()) {
                VStack {
                    ProgressView("Loading")
                        .isHidden(isProgressHidden)
                        .alert(errorMessage, isPresented: $isAlertPresented) {
                            Button("Okay", role: .cancel) { }
                        }
                    
                    Text("START")
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .isHidden(isStartHidden)
                }
            }
        }
        .onAppear(perform: {
            getDataFromDatabase()
        })
    }
    
    func getDataFromDatabase() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        do {
            let result = try viewContext.fetch(request)
            
            for data in result as! [NSManagedObject] {
                let word = data.value(forKey: "word") as! String
                let translation = data.value(forKey: "translation") as! String
                let pronunciation = data.value(forKey: "pronunciation") as! String
                
                WordViewModel.words.append(Word(word: word, translation: translation, pronunciation: pronunciation))
            }
            
            if WordViewModel.words.isEmpty {
                // MARK: The database is empty, let's get the data from Firebase
                getDataFromFirebase()
            } else {
                // MARK: The database isn't empty, let's hide the Progress and show the Start
                hideProgress(hide: true)
            }
        } catch {
            hideProgress(hide: true)
            let error = error as NSError
            showError(error: ": \(error)")
        }
    }
    
    func getDataFromFirebase() {
        databaseReference.getDocuments(completion: {snapshot, error in
            
            if error == nil {
                for i in snapshot!.documents {
                    WordViewModel.words.append(Word(word: i.data()["Word"] as? String, translation: i.data()["Translation"] as? String, pronunciation: i.data()["Pronunciation"] as? String))
                }
                
                if WordViewModel.words.isEmpty {
                    hideProgress(hide: true)
                    showError(error: ": Couldn't get data")
                }else {
                    // MARK: We got the data from Firebase, let's save it to the database
                    saveDataToDatabase()
                }
            } else {
                hideProgress(hide: true)
                showError(error: ": \(String(describing: error))")
            }
        })
    }
    
    func hideProgress(hide: Bool) {
        isProgressHidden = hide
        isStartHidden = !hide
    }
    
    func showError(error: String) {
        errorMessage += error
        isAlertPresented = true
    }
    
    func saveDataToDatabase() {
        for i in WordViewModel.words {
            let item = Item(context: viewContext)
            item.word = i.word
            item.translation = i.translation
            item.pronunciation = i.pronunciation
            
            do {
                try viewContext.save()
            } catch {
                hideProgress(hide: true)
                let error = error as NSError
                showError(error: ": \(error)")
            }
        }
        
        hideProgress(hide: true)
    }
}

struct InitView_Previews: PreviewProvider {
    static var previews: some View {
        InitView()
    }
}
