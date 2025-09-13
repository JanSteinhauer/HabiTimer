//
//  ContentView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var app = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            TasksView().environmentObject(app)
                .tabItem { Label("Tasks", systemImage: "checklist") }

            TimerView().environmentObject(app)
                .tabItem { Label("Timer", systemImage: "timer") }

            HistoryView().environmentObject(app)
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                app.didEnterBackground()
            case .active:
                app.didBecomeActive()
            default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
