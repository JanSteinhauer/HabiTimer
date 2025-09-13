//
//  TasksView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var app: AppState
    @State private var showAdd = false
    @State private var editingTask: HabitTask?

    var body: some View {
        NavigationStack {
            List {
                if app.tasks.isEmpty {
                    ContentUnavailableView("No tasks yet", systemImage: "plus", description: Text("Tap the + to add your first habit."))
                } else {
                    ForEach(app.tasks) { task in
                        TaskRow(task: task)
                            .swipeActions(edge: .trailing) {
                                Button("Edit") {
                                    editingTask = task
                                }
                                .tint(.habitOrange)
                                Button(role: .destructive) { // optional keep/delete
                                    if let idx = app.tasks.firstIndex(of: task) {
                                        app.tasks.remove(at: idx)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete(perform: app.deleteTask)
                    .onMove(perform: app.moveTask)
                }
            }
            .navigationTitle("Habits")
            .toolbar { EditButton() }
            .overlay(alignment: .bottomLeading) {
                // your custom gray circle + orange plus button from earlier
                Button { showAdd = true } label: {
                    ZStack {
                        Circle().fill(Color.gray.opacity(0.2)).frame(width: 56, height: 56)
                        Image(systemName: "plus").font(.system(size: 28, weight: .bold)).foregroundColor(.habitOrange)
                    }
                    .padding(20).shadow(radius: 6)
                }
                .accessibilityLabel("Add Task")
            }
            .sheet(isPresented: $showAdd) {
                AddTaskSheet().environmentObject(app)
            }
            .sheet(item: $editingTask) { t in
                EditEntrySheet(
                    title: "Edit Task",
                    initialName: t.name,
                    initialPriority: t.priority,
                    initialMinutes: max(1, t.plannedSeconds / 60)
                ) { name, priority, minutes in
                    app.updateTask(id: t.id, name: name, priority: priority, minutes: minutes)
                }
            }
        }
    }
}


struct TaskRow: View {
    let task: HabitTask
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(task.priority.color).frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name).font(.headline)
                Text(task.priority.rawValue)
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(formatTime(task.remainingSeconds))
                    .monospaced().font(.title3)
                Text("/" + formatTime(task.plannedSeconds))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

