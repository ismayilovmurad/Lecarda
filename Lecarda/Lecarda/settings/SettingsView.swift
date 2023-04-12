//
//  SettingsView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyReminderEnabled")
    var dailyReminderEnabled = false
    
    @State var dailyReminderTime = Date(timeIntervalSince1970: 0)
    
    @AppStorage("dailyReminderTime")
    var dailyReminderTimeShadow: Double = 0
    
    var body: some View {
        ZStack {
            /// change the background color
            Color(red: 0.914, green: 0.973, blue: 0.976).ignoresSafeArea()
            
            List {
                Text("Settings")
                    .font(.largeTitle)
                    .padding(.bottom, 8)
                
                Section(header: Text("Notifications")) {
                    HStack {
                        Toggle("Daily Reminder", isOn: $dailyReminderEnabled).onChange(of: dailyReminderEnabled, perform: {_ in configureNotification()})
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.325, green: 0.498, blue: 0.906)))
                        DatePicker(
                            "",
                            selection: $dailyReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .disabled(dailyReminderEnabled == false)
                        /// .onChange(of:perform:) is part of the View protocol, so you can use it on any view.
                        .onChange(of: dailyReminderTime, perform: { newValue in
                            /// This copies the number of seconds since the midnight of Jan 1, 1970, as a double value, into the shadow property for the App Storage.
                            dailyReminderTimeShadow = newValue.timeIntervalSince1970
                            configureNotification()})
                        .onAppear {
                            /// With it, every time the Section is displayed, the value stored in the shadow property is converted to a date and stored into dailyReminderTime.
                            dailyReminderTime = Date(timeIntervalSince1970: dailyReminderTimeShadow)
                        }
                    }
                }
            }
            .background(Color(red: 0.914, green: 0.973, blue: 0.976))
            .scrollContentBackground(.hidden)
        }
    }
    
    func configureNotification() {
        if dailyReminderEnabled {
            LocalNotifications.shared.createReminder(
                time: dailyReminderTime)
        } else {
            LocalNotifications.shared.deleteReminder()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
