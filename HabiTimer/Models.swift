//
//  Models.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import SwiftUI
import SwiftData

@Model
final class HabitTask {
    @Attribute(.unique) var id: UUID
    var name: String
    var priorityRaw: String
    var plannedSeconds: Int
    var remainingSeconds: Int
    var createdAt: Date
    var orderIndex: Double  // for custom ordering

    init(id: UUID = UUID(),
         name: String,
         priority: Priority,
         plannedSeconds: Int,
         remainingSeconds: Int? = nil,
         createdAt: Date = .now,
         orderIndex: Double = Date().timeIntervalSince1970)
    {
        self.id = id
        self.name = name
        self.priorityRaw = priority.rawValue
        self.plannedSeconds = plannedSeconds
        self.remainingSeconds = remainingSeconds ?? plannedSeconds
        self.createdAt = createdAt
        self.orderIndex = orderIndex
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }
}

@Model
final class CompletedEntry {
    @Attribute(.unique) var id: UUID
    var name: String
    var priorityRaw: String
    var plannedSeconds: Int
    var finishedAt: Date

    init(id: UUID = UUID(),
         name: String,
         priority: Priority,
         plannedSeconds: Int,
         finishedAt: Date = .now)
    {
        self.id = id
        self.name = name
        self.priorityRaw = priority.rawValue
        self.plannedSeconds = plannedSeconds
        self.finishedAt = finishedAt
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }
}

enum Priority: String, CaseIterable, Codable, Identifiable {
    case high = "High", medium = "Medium", low = "Low"
    var id: String { rawValue }
    var color: Color { switch self { case .high: .red; case .medium: .orange; case .low: .green } }
}
