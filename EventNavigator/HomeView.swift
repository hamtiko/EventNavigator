//
//  HomeView.swift
//  EventNavigator
//
//  Created by Tigran Hambardzumyan on 21.09.2024.
//

import SwiftUI

struct HomeView: View {
    let service: CalendarEventsServiceProtocol

    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle")
                .imageScale(.large)
                .foregroundStyle(.green)
            Text("All set! Everything is ready to go.")
        }
        .padding()
        .task {
            do {
                try await service.requestAccess()
                try await service.fetch()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    HomeView(service: CalendarEventsServicePreview())
}
