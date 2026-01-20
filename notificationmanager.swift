//
//  notificationmanager.swift
//  RandDFit
//
//  Created by Logan Carter on 1/9/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleRandomPrompts(days: Int = 14,
                               promptsPerDay: Int = 4,
                               startHour: Int = 6,
                               endHour: Int = 19,
                               soundFileName: String = "dingding.caf",
                               allowedDifficulties: Set<Difficulty>,
                               beginnerFriendly: Bool) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()

        var idx = 0

        for dayOffset in 0..<days {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }

            var startC = calendar.dateComponents([.year, .month, .day], from: dayDate)
            startC.hour = startHour
            startC.minute = 0

            var endC = calendar.dateComponents([.year, .month, .day], from: dayDate)
            endC.hour = endHour
            endC.minute = 0

            guard let windowStart = calendar.date(from: startC),
                  let windowEnd = calendar.date(from: endC),
                  windowEnd > windowStart else { continue }

            let times = uniqueRandomTimes(count: promptsPerDay, start: windowStart, end: windowEnd)

            for t in times {
                if t <= now { continue }

                let prompt = PromptGenerator.promptLine(
                    allowedDifficulties: allowedDifficulties,
                    beginnerFriendly: beginnerFriendly
                )

                let content = UNMutableNotificationContent()
                content.title = "RandFit — Round Bell"
                content.body = "Ding-ding: \(prompt)"
                if let soundName = UNNotificationSoundName(rawValue: soundFileName) {
                    content.sound = UNNotificationSound(named: soundName)
                }
                
                let triggerDate = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: t)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let request = UNNotificationRequest(identifier: "randfit_\(idx)", content: content, trigger: trigger)
                idx += 1
                do {
                    try await center.add(request)
                } catch {
                    // Ignore individual scheduling failures and continue.
                }
            }
        }
    }

    private func uniqueRandomTimes(count: Int, start: Date, end: Date) -> [Date] {
        let span = end.timeIntervalSince(start)
        let totalMinutes = max(1, Int(span / 60))
        var picks = Set<Int>()

        while picks.count < min(count, totalMinutes) {
            picks.insert(Int.random(in: 0..<totalMinutes))
        }

        return picks.map { start.addingTimeInterval(TimeInterval($0 * 60)) }.sorted()
    }
}
