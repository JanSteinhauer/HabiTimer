//
//  HistoryView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: [SortDescriptor(\CompletedEntry.finishedAt, order: .reverse)])
    private var completed: [CompletedEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var editingCompleted: CompletedEntry?

    private var grouped: [(Date, [CompletedEntry])] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: completed) { cal.startOfDay(for: $0.finishedAt) }
        return groups.keys.sorted(by: >).map { day in
            (day, (groups[day] ?? []).sorted { $0.finishedAt > $1.finishedAt })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.0) { (day, items) in
                    Section(header: Text(day, style: .date)) {
                        ForEach(items) { item in
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
                            .swipeActions { Button("Edit") { editingCompleted = item }.tint(.habitOrange) }
                        }
                    }
                }
            }
            .navigationTitle("Completed")
            .sheet(item: $editingCompleted) { c in
                EditEntrySheet(title: "Edit Completed",
                               initialName: c.name,
                               initialPriority: c.priority,
                               initialMinutes: max(1, c.plannedSeconds/60)) { name, priority, minutes in
                    c.name = name.trimmed()
                    c.priority = priority
                    c.plannedSeconds = max(60, minutes*60)
                    try? modelContext.save()
                }
            }
        }
    }
}
