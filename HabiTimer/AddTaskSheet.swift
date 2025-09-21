//
//  AddTaskSheet.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI
import SwiftData

struct AddTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var priority: Priority = .medium
    @State private var minutes: Double = 25

    var body: some View {
        NavigationStack {
            Form {
                Section("What") { TextField("Task name", text: $name) }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("Duration") {
                    HStack {
                        Slider(value: $minutes, in: 1...180, step: 1)
                        Text("\(Int(minutes)) min").monospaced()
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let secs = Int(minutes) * 60
                        let t = HabitTask(name: name.trimmed(), priority: priority, plannedSeconds: secs)
                        modelContext.insert(t)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.trimmed().isEmpty)
                }
            }
        }
    }
}
