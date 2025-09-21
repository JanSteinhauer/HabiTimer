//
//  TasksView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\HabitTask.orderIndex, order: .forward)]) private var tasks: [HabitTask]
    @State private var showAdd = false
    @State private var editingTask: HabitTask?
    let timerState: TimerState

    var body: some View {
        NavigationStack {
            List {
                if tasks.isEmpty {
                    ContentUnavailableView("No tasks yet", systemImage: "plus", description: Text("Tap the + to add your first habit."))
                } else {
                    ForEach(tasks) { task in
                        TaskRow(name: task.name,
                                    priority: task.priority,
                                    remainingSeconds: task.remainingSeconds,
                                    plannedSeconds: task.plannedSeconds)
                            .swipeActions {
                                Button("Edit") { editingTask = task }.tint(.habitOrange)
                                Button(role: .destructive) {
                                    modelContext.delete(task)
                                    try? modelContext.save()
                                    timerState.rescheduleIfRunning(for: tasks.first)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onMove(perform: move)
                }
            }
            .navigationTitle("Habits")
            .toolbar { EditButton() }
            .overlay(alignment: .bottomLeading) {
                Button { showAdd = true } label: {
                    ZStack {
                        Circle().fill(Color.gray.opacity(0.2)).frame(width: 56, height: 56)
                        Image(systemName: "plus").font(.system(size: 28, weight: .bold)).foregroundColor(.habitOrange)
                    }.padding(20).shadow(radius: 6)
                }
            }
            .sheet(isPresented: $showAdd) { AddTaskSheet() }
            .sheet(item: $editingTask) { t in
                EditEntrySheet(title: "Edit Task",
                               initialName: t.name,
                               initialPriority: t.priority,
                               initialMinutes: max(1, t.plannedSeconds/60)) { name, priority, minutes in
                    t.name = name.trimmed()
                    t.priority = priority
                    t.plannedSeconds = max(60, minutes*60)
                    t.remainingSeconds = min(t.remainingSeconds, t.plannedSeconds)
                    try? modelContext.save()
                    timerState.rescheduleIfRunning(for: tasks.first)
                }
            }
        }
    }

    private func move(from: IndexSet, to: Int) {
        var array = tasks
        array.move(fromOffsets: from, toOffset: to)
        // Reassign orderIndex linearly
        for (i, item) in array.enumerated() { item.orderIndex = Double(i) }
        try? modelContext.save()
        timerState.rescheduleIfRunning(for: tasks.first)
    }
}

private extension HabitTask {
    // lightweight value to reuse existing TaskRow without SwiftData dependency
    var asValue: HabitTaskValue {
        .init(id: id, name: name, priority: priority, plannedSeconds: plannedSeconds, remainingSeconds: remainingSeconds)
    }
}

struct HabitTaskValue: Identifiable, Equatable {
    var id: UUID
    var name: String
    var priority: Priority
    var plannedSeconds: Int
    var remainingSeconds: Int
}
