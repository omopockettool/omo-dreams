//
//  OmoDreamsApp.swift
//  omo-dreams
//
//  Created by Dennis Chicaiza A on 21/6/25.
//

import SwiftUI
import SwiftData

@main
struct OmoDreamsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Dream.self,
            DreamPattern.self,
            Pattern.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
