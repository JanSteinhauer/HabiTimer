//
//  NotificationManager.swift
//  HabiTimer
//
//  Created by Steinhauer, Jan on 11.09.25.
//

import UserNotifications
import SwiftUI

enum NotifyID { static let taskFinish = "task_finish_notification" }

@MainActor
struct NotificationManager {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func scheduleTaskFinish(after seconds: Int, taskName: String) {
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Time’s up"
        content.body = "\(taskName) is done."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let req = UNNotificationRequest(identifier: NotifyID.taskFinish, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    static func cancelTaskFinish() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotifyID.taskFinish])
    }
}
