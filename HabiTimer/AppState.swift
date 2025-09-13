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
    @Published var isRunning = false
    
    private var timer: Timer?
    private var resumeAnchor: Date?
    private var backgroundAnchor: Date?
    
    
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
            guard var head = tasks.first, !isRunning else { return }
            isRunning = true
            resumeAnchor = Date()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        NotificationManager.cancelTaskFinish()
        NotificationManager.scheduleTaskFinish(after: head.remainingSeconds, taskName: head.name)
        
        Haptics.impact(.light)
    }
    
    
    func pause() {
        isRunning = false
        timer?.invalidate(); timer = nil
        resumeAnchor = nil
        NotificationManager.cancelTaskFinish()
        Haptics.impact(.rigid)
    }
    
    func stopAndCompleteCurrent() {
        guard let current = tasks.first else { return }
        let entry = CompletedEntry(name: current.name, priority: current.priority,
                                   plannedSeconds: current.plannedSeconds, finishedAt: .now)
        completed.append(entry)
        tasks.removeFirst()
        pause()
        NotificationManager.cancelTaskFinish()
        Haptics.success()
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
           if head.remainingSeconds > 0 {
               head.remainingSeconds -= 1
               tasks[0] = head
           } else {
               tasks[0] = head
               stopAndCompleteCurrent()
           }
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
    
    func didEnterBackground() {
        backgroundAnchor = Date()
    }
    
    // Call when scene becomes active again
    func didBecomeActive() {
        guard isRunning, var head = tasks.first, let bg = backgroundAnchor else { return }
        let elapsed = Int(Date().timeIntervalSince(bg))
        backgroundAnchor = nil
        guard elapsed > 0 else { return }
        
        // Subtract elapsed time while we were away
        head.remainingSeconds = max(0, head.remainingSeconds - elapsed)
        tasks[0] = head
        
        if head.remainingSeconds == 0 {
            stopAndCompleteCurrent()
        } else {
            // Re-arm UI timer; the *notification* you scheduled at start still fires at the original finish time.
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tick()
            }
        }
    }
    
    
}
