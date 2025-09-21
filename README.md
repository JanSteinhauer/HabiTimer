# 📱 HabiTimer: Minimal Habit Tracker

A clean and simple SwiftUI app for iPhone that helps you **track habits, focus with a timer, and review your progress**.
Built with **SwiftUI**, no external dependencies.

---

## ✨ Features

* **Three tabs, one flow**:

  1. **Tasks** – Create, reorder, and manage your habits.

     * Each task has a **priority (High / Medium / Low)**, a name, and a planned duration.
     * Reorder tasks to decide which one is *active* on the timer screen.
     * Swipe to delete, or drag to reorder.
     * Add new tasks via a **big + button**.
  2. **Timer** – Focus on the top task.

     * Displays a **circular progress timer** for the first task in your list.
     * **Start, pause, and complete** tasks.
     * Remaining time updates live in the task list.
     * On completion, the task is automatically moved to **History**.
  3. **History** – Review what you’ve completed.

     * Shows tasks grouped by **completion day**.
     * Each entry lists **priority, name, and planned duration**.
     * Sorted with the most recent tasks at the top.

* **Persistence** – Tasks and history are saved with `UserDefaults` (using Codable JSON).

* **Lightweight UI** – Minimalist design, clean typography, intuitive gestures.

---

## 🚀 Getting Started

1. Clone or download the project.
2. Open in **Xcode 15+**.
3. Run on an iPhone simulator or device (iOS 17+).

---

## 🛠 Tech Stack

* **Language**: Swift 5.9+
* **UI Framework**: SwiftUI
* **Persistence**: [SwiftData](https://developer.apple.com/xcode/swiftdata/) (`@Model`, `@Query`, `ModelContext`)
* **Architecture**: MVVM-like with `TimerState` as an `ObservableObject` for countdown, notifications & haptics

---

## 🧩 Next Steps / Ideas

* 🔔 **Notifications**: Already implemented when a task finishes; optional daily/start reminders could be added
* 📊 **Streaks & stats**: Show weekly totals, streaks, and completion trends
* 🌈 **Themes**: Customizable priority colors or full app color themes
* ☁️ **iCloud sync**: Turn on CloudKit support in SwiftData for seamless cross-device sync
* 💥 **Haptics**: Already implemented for start/pause/complete; could expand to subtle “tick” haptics or streak milestones

---

## 📸 Screens (conceptual)

* **Tasks Tab** – list with priorities & durations
* **Timer Tab** – circular countdown for current task
* **History Tab** – grouped list of completed tasks

---

## 📄 License

MIT License – free to use, modify, and share.
