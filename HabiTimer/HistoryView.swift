//
//  HistoryView.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var app: AppState

    private var grouped: [(key: Date, value: [CompletedEntry])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: app.completed) { entry in
            calendar.startOfDay(for: entry.finishedAt)
        }
        // Sort days desc, then sort entries per day desc by finishedAt
        return groups.keys.sorted(by: >).map { day in
            let items = (groups[day] ?? []).sorted { $0.finishedAt > $1.finishedAt }
            return (day, items)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.key) { group in
                    let day = group.key
                    let items = group.value
                    Section(header: Text(day, style: .date)) {
                        ForEach(items) { item in
                            HStack(spacing: 12) {
                                Circle().fill(item.priority.color).frame(width: 8, height: 8)
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.headline)
                                    Text(item.priority.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(formatTime(item.plannedSeconds))
                                    .monospaced()
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Completed")
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState())
}
