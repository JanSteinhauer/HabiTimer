//
//  TimerView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\HabitTask.orderIndex, order: .forward)])
    private var tasks: [HabitTask]
    let timerState: TimerState

    var current: HabitTask? { tasks.first }
    var progress: Double {
        guard let t = current, t.plannedSeconds > 0 else { return 0 }
        return 1 - Double(t.remainingSeconds) / Double(t.plannedSeconds)
    }

    var body: some View {
        VStack(spacing: 24) {
            if let t = current {
                Text(t.name).font(.title).bold().multilineTextAlignment(.center).padding(.top, 24)

                ZStack {
                    Circle().stroke(.gray.opacity(0.2), lineWidth: 24)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.habitOrange, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.smooth(duration: 0.2), value: progress)
                    VStack(spacing: 8) {
                        Text(formatTime(t.remainingSeconds)).font(.system(size: 44, weight: .heavy, design: .rounded)).monospaced()
                        Text("remaining").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(width: 280, height: 280)
                .padding(.vertical, 8)

                HStack(spacing: 16) {
                    Button {
                        timerState.completeTop(modelContext: modelContext, top: current)
                    } label: {
                        Label("Done", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    if timerState.isRunning {
                        Button {
                            timerState.pause(modelContext: modelContext)
                        } label: {
                            Label("Pause", systemImage: "pause.fill")
                        }.buttonStyle(.bordered)
                    } else {
                        Button {
                            timerState.start(top: current, modelContext: modelContext)
                        } label: {
                            Label("Start", systemImage: "play.fill")
                        }.buttonStyle(.bordered)
                       
                    }
                }
                .font(.headline)
                .padding(.top, 8)

                Text("Top task controls the timer. Reorder here or on the Tasks tab.")
                    .font(.footnote).foregroundStyle(.secondary).padding(.top, 4)

                Divider().padding(.horizontal)

                // Compact reorderable queue (same as before)
                QueueList(tasks: tasks) { from, to in
                    var arr = tasks
                    arr.move(fromOffsets: from, toOffset: to)
                    for (i, item) in arr.enumerated() { item.orderIndex = Double(i) }
                    try? modelContext.save()
                    timerState.rescheduleIfRunning(for: arr.first)
                }

            } else {
                ContentUnavailableView("No active task", systemImage: "timer", description: Text("Add a task on the Tasks tab.")).padding()
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom)
    }
}

private struct QueueList: View {
    let tasks: [HabitTask]
    let onMove: (IndexSet, Int) -> Void
    @State private var editMode: EditMode = .inactive

    var body: some View {
        HStack { Text("Queue").font(.headline); Spacer(); EditButton().tint(.habitOrange) }
            .padding(.horizontal)

        List {
            ForEach(tasks) { t in
                TaskRow(name: t.name,
                        priority: t.priority,
                        remainingSeconds: t.remainingSeconds,
                        plannedSeconds: t.plannedSeconds)
            }
                .onMove(perform: onMove)
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, $editMode)
        .frame(maxHeight: 260)
    }
}


