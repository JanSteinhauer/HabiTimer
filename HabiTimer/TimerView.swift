//
//  TimerView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var app: AppState

    var current: HabitTask? { app.tasks.first }
    var progress: Double {
        guard let t = current else { return 0 }
        guard t.plannedSeconds > 0 else { return 0 }
        return 1 - Double(t.remainingSeconds) / Double(t.plannedSeconds)
    }

    var body: some View {
        VStack(spacing: 24) {
            if let t = current {
                Text(t.name)
                    .font(.title).bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                ZStack {
                    Circle()
                        .stroke(.gray.opacity(0.2), lineWidth: 24)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AngularGradient(colors: [.blue, .purple], center: .center), style: StrokeStyle(lineWidth: 24, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.smooth(duration: 0.2), value: progress)
                    VStack(spacing: 8) {
                        Text(formatTime(t.remainingSeconds))
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .monospaced()
                        Text("remaining")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(width: 280, height: 280)
                .padding(.vertical, 8)

                HStack(spacing: 16) {
                    Button(action: { app.stopAndCompleteCurrent() }) {
                        Label("Done", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    if app.isRunning {
                        Button(action: { app.pause() }) { Label("Pause", systemImage: "pause.fill") }
                            .buttonStyle(.bordered)
                    } else {
                        Button(action: { app.start() }) { Label("Start", systemImage: "play.fill") }
                            .buttonStyle(.bordered)
                    }
                }
                .font(.headline)
                .padding(.top, 8)

                Text("Top task controls the timer. Reorder on the Tasks tab.")
                    .font(.footnote).foregroundStyle(.secondary)
                    .padding(.top, 4)
            } else {
                ContentUnavailableView("No active task", systemImage: "timer", description: Text("Add a task on the Tasks tab."))
                    .padding()
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    TimerView()
}
