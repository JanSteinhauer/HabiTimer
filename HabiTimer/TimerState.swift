//
//  TimerState.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 21.09.25.
//

import SwiftUI
import SwiftData
import UserNotifications
import Combine

@MainActor
final class TimerState: ObservableObject {
    @Published var isRunning = false
    private var timer: Timer?
    private var backgroundAnchor: Date?

    func start(top task: HabitTask?, modelContext: ModelContext) {
        guard let t = task, !isRunning, t.remainingSeconds > 0 else { return }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { await self?.tick(modelContext: modelContext) }
        }
        NotificationManager.cancelTaskFinish()
        NotificationManager.scheduleTaskFinish(after: t.remainingSeconds, taskName: t.name)
        Haptics.impact(.light)
    }

    func pause(modelContext: ModelContext) {
        isRunning = false
        timer?.invalidate(); timer = nil
        NotificationManager.cancelTaskFinish()
        Haptics.impact(.rigid)
        try? modelContext.save()
    }

    func completeTop(modelContext: ModelContext, top task: HabitTask?) {
        guard let t = task else { return }
        let entry = CompletedEntry(name: t.name, priority: t.priority, plannedSeconds: t.plannedSeconds, finishedAt: .now)
        modelContext.insert(entry)
        modelContext.delete(t)
        pause(modelContext: modelContext)
        NotificationManager.cancelTaskFinish()
        Haptics.success()
        try? modelContext.save()
    }

    func tick(modelContext: ModelContext) async {
        guard let top = try? modelContext.fetch(FetchDescriptor<HabitTask>(predicate: #Predicate { $0.remainingSeconds > 0 },
                                                                           sortBy: [SortDescriptor(\.orderIndex, order: .forward)]))
            .first else { pause(modelContext: modelContext); return }

        if top.remainingSeconds > 0 {
            top.remainingSeconds -= 1
            try? modelContext.save()
        } else {
            completeTop(modelContext: modelContext, top: top)
        }
    }

    func didEnterBackground() { backgroundAnchor = .now }

    func didBecomeActive(modelContext: ModelContext) {
        guard isRunning, let bg = backgroundAnchor else { return }
        backgroundAnchor = nil
        let elapsed = Int(Date().timeIntervalSince(bg))
        guard elapsed > 0 else { return }
        // subtract elapsed from top
        if let top = try? modelContext.fetch(FetchDescriptor<HabitTask>(sortBy: [SortDescriptor(\.orderIndex)])).first {
            top.remainingSeconds = max(0, top.remainingSeconds - elapsed)
            if top.remainingSeconds == 0 {
                completeTop(modelContext: modelContext, top: top)
            } else {
                try? modelContext.save()
            }
        }
    }

    // keep notification aligned if head changes during run
    func rescheduleIfRunning(for top: HabitTask?) {
        guard isRunning, let t = top else {
            NotificationManager.cancelTaskFinish()
            return
        }
        NotificationManager.cancelTaskFinish()
        NotificationManager.scheduleTaskFinish(after: t.remainingSeconds, taskName: t.name)
    }
}
