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
    
    /// instantiate the PersistenceController
    let persistenceController = PersistenceController.shared
    
    /// instantiate the NetworkMonitor
    @StateObject var networkMonitor = NetworkMonitor()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            InitView()
            /// inject the PersistenceController into SwiftUI environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            /// inject the NetworkMonitor into SwiftUI environment
                .environmentObject(networkMonitor)
                .preferredColorScheme(.light)
        }
    }
}
