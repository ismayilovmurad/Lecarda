//
//  Persistence.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    
    init() {
        container = NSPersistentCloudKitContainer(name: "Lecarda")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
