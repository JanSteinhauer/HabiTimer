//
//  Models.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import Foundation
import SwiftUI

enum Priority: String, CaseIterable, Codable, Identifiable {
    case high = "High", medium = "Medium", low = "Low"
    var id: String { rawValue }
    var color: Color {
        switch self { case .high: .red; case .medium: .orange; case .low: .green }
    }
}

struct HabitTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var priority: Priority
    /// Planned duration in seconds for the session
    var plannedSeconds: Int
    /// Remaining seconds for the current session (mirrors timer screen)
    var remainingSeconds: Int
    var createdAt: Date = .now
    var completedAt: Date? = nil
}

struct CompletedEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var priority: Priority
    var plannedSeconds: Int
    var finishedAt: Date
}
