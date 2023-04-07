//
//  LecardaApp.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI
import FirebaseCore

@main
struct LecardaApp: App {
    
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            InitView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
