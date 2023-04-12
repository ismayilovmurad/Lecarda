//
//  NetworkMonitor.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 08.04.23.
//

import Foundation
import Network

/// NetworkMonitor conforms to @ObservableObject protocol so we can listen for any changes and update the UI accordingly.
/// this network monitor can be used in both UIKit and SwiftUI views.
class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
