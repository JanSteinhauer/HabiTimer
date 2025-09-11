//
//  AddTaskSheet.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var priority: Priority = .medium
    @State private var minutes: Double = 25

    var body: some View {
        NavigationStack {
            Form {
                Section("What") {
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
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        app.addTask(name: name.trimmed(), priority: priority, minutes: Int(minutes))
                        dismiss()
                    }
                    .disabled(name.trimmed().isEmpty)
                }
            }
        }
    }
}
#Preview {
    AddTaskSheet()
}
