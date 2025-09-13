//
//  HistoryView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var app: AppState
    @State private var editingCompleted: CompletedEntry?

    private var grouped: [(key: Date, value: [CompletedEntry])] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: app.completed) { cal.startOfDay(for: $0.finishedAt) }
        return groups.keys.sorted(by: >).map { day in
            (day, (groups[day] ?? []).sorted { $0.finishedAt > $1.finishedAt })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.key) { group in
                    Section(header: Text(group.key, style: .date)) {
                        ForEach(group.value) { item in
                            HStack(spacing: 12) {
                                Circle().fill(item.priority.color).frame(width: 8, height: 8)
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.headline)
                                    Text(item.priority.rawValue).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(formatTime(item.plannedSeconds)).monospaced().font(.subheadline)
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing) {
                                Button("Edit") { editingCompleted = item }
                                    .tint(.habitOrange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Completed")
            .sheet(item: $editingCompleted) { c in
                EditEntrySheet(
                    title: "Edit Completed",
                    initialName: c.name,
                    initialPriority: c.priority,
                    initialMinutes: max(1, c.plannedSeconds / 60)
                ) { name, priority, minutes in
                    app.updateCompleted(id: c.id, name: name, priority: priority, minutes: minutes)
                }
            }
        }
    }
}


#Preview {
    HistoryView()
        .environmentObject(AppState())
}
