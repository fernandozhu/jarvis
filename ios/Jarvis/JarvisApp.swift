//
//  JarvisApp.swift
//  Jarvis
//
//  Created by Fernando Zhu on 1/05/23.
//

import SwiftUI

@main
struct JarvisApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
