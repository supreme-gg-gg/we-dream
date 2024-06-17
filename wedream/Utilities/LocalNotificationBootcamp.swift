//
//  LocalNotificationBootcamp.swift
//  HK
//
//  Created by zyf on 2024-06-09.
//

import SwiftUI
import UserNotifications

struct NotificationViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}


class ViewController: UIViewController{
    override func viewDidLoad(){
        super.viewDidLoad()
        checkForPermission()
    }
    func checkForPermission(){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .notDetermined:
                    notificationCenter.requestAuthorization(options: [.alert,.sound]){ didAllow, error in
                        if didAllow{
                            self.dispatchNotification()
                        }
                    }
                case .denied:
                    return
                case .authorized:
                    self.dispatchNotification()
                default:
                    return
            }
        }
    }
    func dispatchNotification(){
        let identifier = "My-Sleep-Notification"
        let title = "10PM RIGNT NOW! TIME TO SLEEP!"
        let body = "DON'T FORGET THE SLEEP GAME"
        let hour = 15
        let minute = 22
        let isDaily = true
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
}
