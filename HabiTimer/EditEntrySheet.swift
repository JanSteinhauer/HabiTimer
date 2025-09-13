//
//  EditEntrySheet.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 13.09.25.
//

import SwiftUI

struct EditEntrySheet: View {
    let title: String
    let initialName: String
    let initialPriority: Priority
    /// minutes
    let initialMinutes: Int
    let onSave: (_ name: String, _ priority: Priority, _ minutes: Int) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var priority: Priority = .medium
    @State private var minutes: Double = 25

    init(title: String,
         initialName: String,
         initialPriority: Priority,
         initialMinutes: Int,
         onSave: @escaping (_ name: String, _ priority: Priority, _ minutes: Int) -> Void) {
        self.title = title
        self.initialName = initialName
        self.initialPriority = initialPriority
        self.initialMinutes = initialMinutes
        self.onSave = onSave
        _name = State(initialValue: initialName)
        _priority = State(initialValue: initialPriority)
        _minutes = State(initialValue: Double(initialMinutes))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Task name", text: $name)
                }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Duration") {
                    HStack {
                        Slider(value: $minutes, in: 1...180, step: 1)
                        Text("\(Int(minutes)) min").monospaced()
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, priority, Int(minutes))
                        dismiss()
                    }
                    .disabled(name.trimmed().isEmpty)
                }
            }
        }
    }
}
