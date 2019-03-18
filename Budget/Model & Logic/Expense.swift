//
//  Expense.swift
//  Budget
//
//  Created by Tudor Croitoru on 05.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation
import UserNotifications

class Expense: NSObject, NSCoding, Codable {
    
    
    var title: String
    var price: Double
    var currency: Currency
    var datePurchased: Date
    var notificationsOn = false
    let notificationUuid: String = UUID().uuidString
    
    init(title: String, price: Double, currency: String, datePurchased: Date?) {
        self.title           = title
        self.price           = price
        self.datePurchased   = (datePurchased != nil) ? datePurchased! : Date()
        self.currency        = Currency(isoCode: currency)
    }
    
    static func == (rhs: Expense, lhs: Expense) -> Bool {
        return  rhs.title           == lhs.title &&
                rhs.price           == lhs.price &&
                rhs.currency        == lhs.currency &&
                rhs.notificationsOn == lhs.notificationsOn &&
                Date.areSameDay(date1: rhs.datePurchased, date2: lhs.datePurchased)
    }
    
    
    ///
    ///
    /// - Parameter onOrOff:
    ///     - true - turns notifications on for this expense
    ///     - false - turns notifications off for this specific expense
    func turnNotifications(onOrOff: Bool, closure: (()->())?) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        if onOrOff{
            notificationCenter.getNotificationSettings { (notificationSettings) in
                switch notificationSettings.authorizationStatus {
                    
                case .notDetermined:
                    // Ask for permission
                    notificationCenter.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (allowed, err) in
                        //if allowed, register notifications for this expense
                        //if denied, call out the decision.
                        if allowed {
                            let content = self.createNotificationContent()
                            self.addNotification(content: content)
                            
                        } else {
                            closure?()
                        }
                    })
                case .denied:
                    //call out the request for notification
                    closure?()
                case .authorized:
                    //register notification
                    let content = self.createNotificationContent()
                    self.addNotification(content: content)
                case .provisional:
                    break
                @unknown default:
                    return
                }
            }
        } else {
            //deregister the notification
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.notificationUuid])
        }
        
        self.notificationsOn = onOrOff
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "expenseTitleKey")
        aCoder.encode(price, forKey: "expensePriceForeverKey")
        aCoder.encode(datePurchased, forKey: "expenseDateKey")
        aCoder.encode(currency.isoCode, forKey: "currencyKey")
        aCoder.encode(notificationsOn, forKey: "notificationsOnKey")
    }
    
    required init(coder aDecoder: NSCoder) {
        title           = aDecoder.decodeObject(forKey: "expenseTitleKey") as! String
        price           = aDecoder.decodeDouble(forKey: "expensePriceForeverKey")
        datePurchased   = aDecoder.decodeObject(forKey: "expenseDateKey") as! Date
        currency        = Currency(isoCode: aDecoder.decodeObject(forKey: "currencyKey") as! String)
        notificationsOn = aDecoder.decodeBool(forKey: "notificationsOnKey")
    }
    
    func recurringExpense() -> RecurringExpense {
        return RecurringExpense(title: self.title,
                                price: self.price,
                                currency: self.currency.isoCode,
                                datePurchased: self.datePurchased)
    }
    
    func addNotification(content: UNMutableNotificationContent) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        var dateComponents      = DateComponents()
        dateComponents.day      = Calendar.autoupdatingCurrent.component(.day, from: self.datePurchased)
        dateComponents.hour     = 10
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: self.notificationUuid, content: content, trigger: trigger)
        notificationCenter.add(request) { (err) in
            if err != nil {
                print(err?.localizedDescription as Any)
            }
        }
    }
    
    func createNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = self.title + " reminder"
        content.body = "If you haven't already, remember today to pay your recurring expense: " + self.title + "."
        content.sound = .default
        
        return content
    }

}
