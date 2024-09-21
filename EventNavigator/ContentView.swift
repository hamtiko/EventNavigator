//
//  ContentView.swift
//  EventNavigator
//
//  Created by Tigran Hambardzumyan on 18.09.2024.
//

import SwiftUI

struct ContentView: View {
    let calendarEventsService = CalendarEventsService()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView(service: calendarEventsService)
            }
            Tab("Events", systemImage: "calendar") {
                EventsView(service: calendarEventsService)
            }
            Tab("Settings", systemImage: "gear") {
                Text("Settings")
            }
        }
    }
}

#Preview {
    ContentView()
}
