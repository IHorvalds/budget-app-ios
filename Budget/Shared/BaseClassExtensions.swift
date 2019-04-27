//
//  BaseClassExtensions.swift
//  Budget
//
//  Created by Tudor Croitoru on 14/03/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import UIKit

extension NSLocale {
    
    static func currencySymbolFromCode(code: String) -> String? {
        let localeIdentifier = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.currencyCode.rawValue : code])
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        return locale.object(forKey: NSLocale.Key.currencySymbol) as? String
    }
    
}


extension Date {
    static func areSameDay(date1: Date, date2: Date) -> Bool {
        
//        var calendar        = Calendar(identifier: .gregorian)
//        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        
        let calendar = NSLocale.autoupdatingCurrent.calendar
        
        let comparison = calendar.compare(date1, to: date2, toGranularity: .day)
        
        if comparison == .orderedSame {
            return true
        }
        
        return false
    }
    
    func getSameDayNextMonth() -> Date {
        var calendar        = Calendar(identifier: .gregorian)
        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        
        var dateComponents = DateComponents()
        dateComponents.month = 1
        return calendar.date(byAdding: dateComponents, to: self)!
    }
}

extension CGFloat {
    func mapCGFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        if (0.0...255.0).contains(self) {
            let delta = abs(max - min)
            if self > 0 {
                return self/255.0 * delta + min //starting from min and adding the number of steps (of 255 possible steps) * the delta
            } else {
                return min
            }
            
        } else if self < 0.0 {
            return min
        } else {
            return max
        }
    }
    
}
