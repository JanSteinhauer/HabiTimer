//
//  TaskRow.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 21.09.25.
//

import SwiftUI

struct TaskRow: View {
    let name: String
    let priority: Priority
    let remainingSeconds: Int
    let plannedSeconds: Int

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(priority.color).frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.headline)
                Text(priority.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(formatTime(remainingSeconds))
                    .monospaced().font(.title3)
                Text("/" + formatTime(plannedSeconds))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
