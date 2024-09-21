//
//  EventsView.swift
//  EventNavigator
//
//  Created by Tigran Hambardzumyan on 21.09.2024.
//

import SwiftUI

struct EventsView: View {
    @StateObject var viewModel: EventsViewModel

    init(service: any CalendarEventsServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(service: service))
    }

    var body: some View {
        List {
            ForEach(viewModel.events) { event in
                Button(action: {
                    if let url = URL(string: event.url) {
                        Task {
                            await UIApplication.shared.open(url)
                        }
                    }
                }) {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        HStack {
                            Text(event.date, style: .date)
                            Text("-")
                            Text(event.date, style: .time)
                        }
                    }
                }
                .tint(.primary)
            }
        }
        .listStyle(.grouped)
        .task {
            await viewModel.fetch()
        }
    }
}

#Preview {
    EventsView(service: CalendarEventsServicePreview())
}

@Observable
final class CalendarEventsServicePreview: CalendarEventsServiceProtocol {
    var scheduledEvents: [EventWithNavigation] {
        get async {
            [
                EventWithNavigation(id: "1", title: "Event 1", date: Date(), url: "https://yandex.ru/maps/1"),
                EventWithNavigation(id: "2", title: "Event 2", date: Date(), url: "https://yandex.ru/maps/2"),
                EventWithNavigation(id: "3", title: "Event 3", date: Date(), url: "https://yandex.ru/maps/3"),
            ]
        }
    }

    func requestAccess() async throws {}

    func fetch() async throws {}
}
