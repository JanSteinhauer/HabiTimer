//
//  ContentView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var app = AppState()

    var body: some View {
        TabView {
            TasksView()
                .environmentObject(app)
                .tabItem { Label("Tasks", systemImage: "checklist") }

            TimerView()
                .environmentObject(app)
                .tabItem { Label("Timer", systemImage: "timer") }

            HistoryView()
                .environmentObject(app)
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
    }
}

#Preview {
    ContentView()
}
