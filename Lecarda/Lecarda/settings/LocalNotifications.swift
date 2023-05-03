//
//  LocalNotifications.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 09.04.23.
//

import UserNotifications

class LocalNotifications {
    static var shared = LocalNotifications()
    
    var lastKnownPermission: UNAuthorizationStatus?
    var userNotificationCenter: UNUserNotificationCenter { UNUserNotificationCenter.current() }
    
    private init() {
        userNotificationCenter.getNotificationSettings { settings in
            let permission = settings.authorizationStatus
            
            switch permission {
            case .ephemeral, .provisional: fallthrough
                
            case .notDetermined:
                self.requestLocalNotificationPermission(completion: { _ in })
                
            case .authorized, .denied:
                break
                
            @unknown default: break
            }
        }
    }
    
    func createReminder(time: Date) {
        deleteReminder()
        userNotificationCenter.getNotificationSettings { settings in
            let content = UNMutableNotificationContent()
            content.title = "Lecarda"
            content.subtitle = "İngilizce öğrenme zamanı!"
            
            if settings.soundSetting == .enabled {
                content.sound = UNNotificationSound.default
            }
            
            var date = DateComponents()
            date.calendar = Calendar.current
            date.timeZone = TimeZone.current
            date.hour = Calendar.current.component(.hour, from: time)
            date.minute = Calendar.current.component(.minute, from: time)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            
            let reminder = UNNotificationRequest(
                identifier: "ananas-reminder",
                content: content,
                trigger: trigger
            )
            
            self.userNotificationCenter.add(reminder)
        }
    }
    
    func deleteReminder() {
        userNotificationCenter.removeAllDeliveredNotifications()
    }
    
    func requestLocalNotificationPermission(completion: @escaping (_ granted: Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        userNotificationCenter.requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false)
                    return
                }
                
                guard granted else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
}
