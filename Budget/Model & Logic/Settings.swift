//
//  Settings.swift
//  Budget
//
//  Created by Tudor Croitoru on 08/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import UIKit

class Settings: NSObject, NSCoding, Codable {
    
    
    
    var userName: String
    var userImage: String //MARK: change user's image in settings to the value in defaults. That's an actual image, not a string.
    var incomeAmount: Double
    var incomeCurrency: String
    var preferredCurrency: String
    var recurringPayment = true
    var paymentDate: Date?
    var mustLastUntil: Date?
    var recurringExpenses: [RecurringExpense]
    var savingsTarget: Double
    
    enum Attribute: Int {
        case UserName
        case IncomeAmount
        case IncomeCurrency
        case PreferredCurrency
        case PaymentDate
        case MustLastUntil
        case SavingsTarget
    }
    
    static var standardSettings = Settings(userName: "Your name here", userImage: #imageLiteral(resourceName: "Human"), incomeAmount: 0.0, incomeCurrency: "", preferredCurrency: NSLocale.current.currencyCode ?? "", recurringPayment: true, paymentDate: nil, mustLastUntil: nil, recurringExpenses: [], savingsTarget: nil)
    
    static func encodeImageToBase64(image: UIImage) -> String {
        let imageData: Data = image.pngData()!
        return imageData.base64EncodedString()
    }
    
    static func decodeImageFromBase64(strBase64: String) -> UIImage {
        let imageData = Data(base64Encoded: strBase64)
        if  let imageData = imageData,
            let image = UIImage(data: imageData) {
            
            return image
        }
        
        return #imageLiteral(resourceName: "Human")
    }
    
    init(userName: String, userImage: UIImage, incomeAmount: Double, incomeCurrency: String, preferredCurrency: String, recurringPayment: Bool, paymentDate: Date?, mustLastUntil: Date?, recurringExpenses: [RecurringExpense], savingsTarget: Double?) {
        
        self.userName           = userName
        self.userImage          = Settings.encodeImageToBase64(image: userImage)
        self.incomeAmount       = incomeAmount
        self.incomeCurrency     = incomeCurrency
        self.preferredCurrency  = preferredCurrency
        self.recurringPayment   = recurringPayment
        self.paymentDate        = paymentDate
        self.mustLastUntil      = mustLastUntil
        self.recurringExpenses  = recurringExpenses
        self.savingsTarget      = savingsTarget ?? 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.userName           = aDecoder.decodeObject(forKey: userNameKey) as! String
        self.userImage          = aDecoder.decodeObject(forKey: userImageKey) as! String
        self.incomeAmount       = aDecoder.decodeDouble(forKey: incomeAmountKey)
        self.incomeCurrency     = aDecoder.decodeObject(forKey: incomeCurrencyKey) as! String
        self.preferredCurrency  = aDecoder.decodeObject(forKey: preferredCurrencyKey) as! String
        self.recurringPayment   = aDecoder.decodeBool(forKey: recurringPaymentKey)
        self.paymentDate        = aDecoder.decodeObject(forKey: paymentDateKey) as? Date
        self.mustLastUntil      = aDecoder.decodeObject(forKey: mustLastUntilKey) as? Date
        self.recurringExpenses  = aDecoder.decodeObject(forKey: recurringExpensesKey) as! [RecurringExpense]
        self.savingsTarget      = aDecoder.decodeDouble(forKey: savingsKey)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(userName,           forKey: userNameKey)
        aCoder.encode(userImage,          forKey: userImageKey)
        aCoder.encode(incomeAmount,       forKey: incomeAmountKey)
        aCoder.encode(incomeCurrency,     forKey: incomeCurrencyKey)
        aCoder.encode(preferredCurrency,  forKey: preferredCurrencyKey)
        aCoder.encode(recurringPayment,   forKey: recurringPaymentKey)
        aCoder.encode(paymentDate,        forKey: paymentDateKey)
        aCoder.encode(mustLastUntil,      forKey: mustLastUntilKey)
        aCoder.encode(recurringExpenses,  forKey: recurringExpensesKey)
        aCoder.encode(savingsTarget,      forKey: savingsKey)
    }
    
    func addRecurringExpense(expense: RecurringExpense) {
        let budgets: [BudgetForDay]? = try? BudgetForDay.getBudgetsFromDefaults()
        self.recurringExpenses.append(expense)
        let eList = expense.createExpensesFor(settings: self)
        BudgetForDay.addExpensesToMatchingBudget(expenseList: eList, budgets: budgets)
        
        if let budgets = budgets {
            
            BudgetForDay.saveBudgetsToDefaults(budgets: budgets)
        }
    }
    
    func removeRecurringExpense(at: Int) {
        if at < self.recurringExpenses.count {
            
            let budgets: [BudgetForDay]? = try? BudgetForDay.getBudgetsFromDefaults()
            let eList = self.recurringExpenses[at].createExpensesFor(settings: self).filter({$0.datePurchased >= Date()}) //remove only the ones the user hasn't already paid
            self.recurringExpenses.remove(at: at)
            BudgetForDay.removeExpensesFromMatchingBudget(expenseList: eList, budgets: budgets)
            
            if let budgets = budgets {
                
                BudgetForDay.saveBudgetsToDefaults(budgets: budgets)
            }
        }
    }
    
    func saveSettingsToDefaults() {
        let settingsData = NSKeyedArchiver.archivedData(withRootObject: self)
        
        defaults.set(settingsData as Data,  forKey: settingsKey)
    }
    
    static func getSettingsFromDefaults() throws -> Settings {
        //MARK: Initialising and error just in case
        let error: NSError = NSError(domain: NSErrorDomain.init(string: "Unable to get settings from UserDefaults.") as String, code: -1, userInfo: nil)
        
        
        guard let settingsData = defaults.value(forKey: settingsKey) as? Data else {
            throw error }
        
        if let settings = NSKeyedUnarchiver.unarchiveObject(with: settingsData) as? Settings {
            return settings
        } else {
            throw error
        }
    }
    
    func saveSettingField(string: String, field: Settings.Attribute) {
        if field == .UserName {
            self.userName = string
        }
        if field == .IncomeCurrency {
            self.incomeCurrency = string
        }
        
        if field == .PreferredCurrency {
            self.preferredCurrency = string
        }
    }
    
    func saveSettingField(double: Double, field: Settings.Attribute) {
        if field == .IncomeAmount {
            self.incomeAmount = double
        }
        
        if field == .SavingsTarget {
            self.savingsTarget = double
        }
    }
    
    func saveSettingField(date: Date, field: Settings.Attribute) {
        if field == .PaymentDate {
            self.paymentDate = date
        }
        
        if field == .MustLastUntil {
            self.mustLastUntil = date
        }
    }
}
