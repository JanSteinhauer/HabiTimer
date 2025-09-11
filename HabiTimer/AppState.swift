//
//  AppState.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var tasks: [HabitTask] = [] { didSet { persist(); rescheduleFinishIfNeeded() } }
    @Published var completed: [CompletedEntry] = [] { didSet { persist() } }

    // Timer state
    @Published var isRunning = false
    private var timer: Timer?

    private let storeKey = "HabiTimerStore_v1"

    init() { load() }

    func addTask(name: String, priority: Priority, minutes: Int) {
        let secs = max(1, minutes) * 60
        let t = HabitTask(name: name, priority: priority, plannedSeconds: secs, remainingSeconds: secs)
        tasks.append(t)
    }

    func deleteTask(at offsets: IndexSet) { tasks.remove(atOffsets: offsets) }
    func moveTask(from: IndexSet, to: Int) { tasks.move(fromOffsets: from, toOffset: to) }

    func start() {
        guard let head = tasks.first, !isRunning else { return }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }

        NotificationManager.cancelTaskFinish()
        NotificationManager.scheduleTaskFinish(after: head.remainingSeconds, taskName: head.name)

        Haptics.impact(.light) // subtle tap when starting
    }

    func pause() {
        isRunning = false
        timer?.invalidate(); timer = nil
        NotificationManager.cancelTaskFinish()

        Haptics.impact(.rigid) // slightly different tap when pausing
    }

    func stopAndCompleteCurrent() {
        guard let current = tasks.first else { return }
        let entry = CompletedEntry(name: current.name, priority: current.priority,
                                   plannedSeconds: current.plannedSeconds, finishedAt: .now)
        completed.append(entry)
        tasks.removeFirst()
        pause()
        NotificationManager.cancelTaskFinish()

        Haptics.success() // success haptic when completing
    }


    private func rescheduleFinishIfNeeded() {
        guard isRunning, let head = tasks.first else {
            NotificationManager.cancelTaskFinish()
            return
        }
        NotificationManager.cancelTaskFinish()
        NotificationManager.scheduleTaskFinish(after: head.remainingSeconds, taskName: head.name)
    }



    private func tick() {
        guard !tasks.isEmpty else { pause(); return }
        var head = tasks[0]
        if head.remainingSeconds > 0 { head.remainingSeconds -= 1 } else { // auto-complete
            tasks[0] = head
            stopAndCompleteCurrent()
            return
        }
        tasks[0] = head // write-back to reflect on list
    }

    // MARK: - Persistence helpers
    private struct Store: Codable { var tasks: [HabitTask]; var completed: [CompletedEntry] }

    private func persist() {
        let store = Store(tasks: tasks, completed: completed)
        if let data = try? JSONEncoder().encode(store) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storeKey),
              let store = try? JSONDecoder().decode(Store.self, from: data) else { return }
        self.tasks = store.tasks
        self.completed = store.completed
    }
}
