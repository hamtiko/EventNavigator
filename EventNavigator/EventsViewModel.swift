//
//  EventsViewModel.swift
//  EventNavigator
//
//  Created by Tigran Hambardzumyan on 21.09.2024.
//

import Foundation
import SwiftUI

@MainActor
final class EventsViewModel: ObservableObject {
    @Published var events: [EventWithNavigation] = []

    private let service: CalendarEventsServiceProtocol

    init(service: CalendarEventsServiceProtocol) {
        self.service = service
    }

    func fetch() async {
        events = await service.scheduledEvents
    }
}
