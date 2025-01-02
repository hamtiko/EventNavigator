//
//  LocalNotificationsScheduler.swift
//  EventNavigator
//
//  Created by Tigran Hambardzumyan on 18.09.2024.
//

import Foundation
@preconcurrency import UserNotifications
import UIKit

struct EventWithNavigation: Identifiable {
    let id: String
    let title: String
    let date: Date
    let url: String
    let alarm: Date?
}

final class LocalNotificationsScheduler: NSObject, Sendable {
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorization() async throws {
        try await center.requestAuthorization(options: [.alert, .sound, .carPlay])
    }

    func removeAllSchedules() {
        center.removeAllPendingNotificationRequests()
    }

    func getScheduledEvents() async -> [EventWithNavigation] {
        let requests = await center.pendingNotificationRequests()
        return requests.map {
            EventWithNavigation(
                id: $0.content.userInfo["id"] as? String ?? UUID().uuidString,
                title: $0.content.title,
                date: ($0.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() ?? Date(),
                url: $0.content.userInfo["url"] as? String ?? "",
                alarm: ($0.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            )
        }
    }

    func schedule(event: EventWithNavigation) async throws {
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = "Tap to start navigation"
        content.sound = UNNotificationSound.defaultCritical
        content.interruptionLevel = .timeSensitive
        content.userInfo = [
            "url": event.url,
            "id": event.id
        ]

        let calendar = Calendar.current
        var scheduleDate = calendar.date(byAdding: .minute, value: -30, to: event.date)
        if let alarm = event.alarm {
            scheduleDate = alarm
        }
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleDate!)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        try await center.add(request)
    }

    deinit {
        print("LocalNotificationsScheduler deinit")
    }
}

extension LocalNotificationsScheduler: @preconcurrency UNUserNotificationCenterDelegate {
    @MainActor
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if let urlString = response.notification.request.content.userInfo["url"] as? String,
           let url = URL(string: urlString) {
            await UIApplication.shared.open(url)
        }
    }
}
