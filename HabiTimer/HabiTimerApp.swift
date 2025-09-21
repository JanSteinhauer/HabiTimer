//
//  HabiTimerApp.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI
import SwiftData

@main
struct HabiTimerApp: App {
    init() {
           NotificationManager.requestAuthorization()
       }
    
    var body: some Scene {
        WindowGroup {
            ContentView().tint(.habitOrange)
        }
        .modelContainer(for: [HabitTask.self, CompletedEntry.self])
    }
}
