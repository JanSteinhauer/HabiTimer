//
//  TimerView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var editMode: EditMode = .inactive

    var current: HabitTask? { app.tasks.first }
    var progress: Double {
        guard let t = current, t.plannedSeconds > 0 else { return 0 }
        return 1 - Double(t.remainingSeconds) / Double(t.plannedSeconds)
    }

    var body: some View {
        VStack(spacing: 24) {
            if let t = current {
                Text(t.name)
                    .font(.title).bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                // Big circular countdown
                ZStack {
                    Circle()
                        .stroke(.gray.opacity(0.2), lineWidth: 24)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.habitOrange,
                                style: StrokeStyle(lineWidth: 24, lineCap: .round))
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

                // Controls
                HStack(spacing: 16) {
                    Button(action: { app.stopAndCompleteCurrent() }) {
                        Label("Done", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    if app.isRunning {
                        Button(action: { app.pause() }) {
                            Label("Pause", systemImage: "pause.fill")
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button(action: { app.start() }) {
                            Label("Start", systemImage: "play.fill")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .font(.headline)
                .padding(.top, 8)


                
                List {
                    ForEach(app.tasks) { task in
                        TaskRow(task: task)
                            .contentShape(Rectangle())
                    }
                    .onMove(perform: app.moveTask)
                   
                }
                .listStyle(.insetGrouped)
                .environment(\.editMode, $editMode)
                .frame(maxHeight: 260)

            } else {
                ContentUnavailableView("No active task",
                                       systemImage: "timer",
                                       description: Text("Add a task on the Tasks tab."))
                    .padding()
            }

            Spacer(minLength: 0)
        }
        .padding(.bottom)
    }
}

#Preview {
    TimerView()
        .environmentObject(AppState())
}

