//
//  ContentView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var timerState = TimerState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            TasksView(timerState: timerState)
                .tabItem { Label("Tasks", systemImage: "checklist") }

            TimerView(timerState: timerState)
                .tabItem { Label("Timer", systemImage: "timer") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background: timerState.didEnterBackground()
            case .active:     timerState.didBecomeActive(modelContext: modelContext)
            default: break
            }
        }
    }
}


#Preview {
    ContentView()
}
