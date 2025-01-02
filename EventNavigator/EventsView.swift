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
                            Text(event.alarm ?? event.date, style: .date)
                            Text("-")
                            Text(event.alarm ?? event.date, style: .time)
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
