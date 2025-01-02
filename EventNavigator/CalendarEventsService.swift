//
//  CalendarEventsService.swift
//  EventNavigator
//
//  Created by Tigran Hambardzumyan on 18.09.2024.
//

import Foundation
@preconcurrency import EventKit

protocol CalendarEventsServiceProtocol: Sendable {
    var scheduledEvents: [EventWithNavigation] { get async }
    func requestAccess() async throws
    func fetch() async throws
}

final class CalendarEventsService: CalendarEventsServiceProtocol {
    private static let yandexURLPrefix = "https://yandex.ru/maps/"
    private let store = EKEventStore()
    private let localNotificationsScheduler = LocalNotificationsScheduler()

    var scheduledEvents: [EventWithNavigation] {
        get async {
            await localNotificationsScheduler.getScheduledEvents()
        }
    }

    func requestAccess() async throws {
        try await store.requestFullAccessToEvents()
        try await localNotificationsScheduler.requestAuthorization()
    }

    func fetch() async throws {
        // Get the appropriate calendar.
        let calendar = Calendar.current

        // Create the end date components.
        var oneWeekFromNowComponents = DateComponents()
        oneWeekFromNowComponents.day = 7
        let oneWeekFromNow = calendar.date(byAdding: oneWeekFromNowComponents, to: Date(), wrappingComponents: false)

        // Create the predicate from the event store's instance method.
        var predicate: NSPredicate? = nil
        if let endNow = oneWeekFromNow {
            predicate = store.predicateForEvents(withStart: Date(), end: endNow, calendars: nil)
        }

        // Fetch all events that match the predicate.
        var events: [EKEvent] = []
        if let aPredicate = predicate {
            events = store.events(matching: aPredicate)
        }
        events = events.filter { !$0.isAllDay && $0.hasNotes && ($0.notes ?? "").contains(Self.yandexURLPrefix) }

        localNotificationsScheduler.removeAllSchedules()

        for event in events {
            guard let notes = event.notes, let url = getUrl(from: notes) else { continue }
            var alarm: Date?
            if let absoluteAlarmDate = event.alarms?.first?.absoluteDate {
                alarm = absoluteAlarmDate
            } else if let relativeOffset = event.alarms?.first?.relativeOffset {
                alarm = event.startDate.addingTimeInterval(relativeOffset)
            }
            let eventToSchedule = EventWithNavigation(
                id: "\(event.calendarItemIdentifier)-\(event.startDate.timeIntervalSince1970)",
                title: event.title,
                date: event.startDate,
                url: url,
                alarm: alarm
            )
            try await localNotificationsScheduler.schedule(event: eventToSchedule)
        }
    }

    private func getUrl(from notes: String) -> String? {
        // Define the regular expression for detecting URLs starting with "https://yandex.ru/maps/"
        let pattern = #"https://yandex\.ru/maps/[^\s]+"#

        do {
            // Create the regular expression object
            let regex = try NSRegularExpression(pattern: pattern, options: [])

            // Search for the first match of the regex in the description string
            if let match = regex.firstMatch(in: notes, options: [], range: NSRange(location: 0, length: notes.utf16.count)) {
                if let range = Range(match.range, in: notes) {
                    return String(notes[range])
                }
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }
        return nil
    }

    deinit {
        print("CalendarEventsService deinit")
    }
}

final class CalendarEventsServicePreview: CalendarEventsServiceProtocol {
    var scheduledEvents: [EventWithNavigation] {
        get async {
            [
                EventWithNavigation(
                    id: "1",
                    title: "Event 1",
                    date: Date(),
                    url: "https://yandex.ru/maps/1",
                    alarm: Date()
                ),
                EventWithNavigation(id: "2", title: "Event 2", date: Date(), url: "https://yandex.ru/maps/2", alarm: nil),
                EventWithNavigation(id: "3", title: "Event 3", date: Date(), url: "https://yandex.ru/maps/3", alarm: nil),
            ]
        }
    }

    func requestAccess() async throws {}

    func fetch() async throws {}
}
