//
//  Keys.swift
//  Budget
//
//  Created by Tudor Croitoru on 09.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation
import UIKit

let defaultsSuiteName   = "dailyBudgetSuite"
let defaults            = UserDefaults(suiteName: "dailyBudgetSuite")!

// MARK: OLD!!!! UserDefaults keys
let dateReceivedKey = "dateReceived"
let lastsUntilKey = "lastsUntil"
let notificationsAccessKey = "notificationAccess"
let rentDueDateKey = "rentDueDate"
let budgetKey = "moneyReceived"
let rentAmountKey = "rentAmount"
let sentCurrencyKey = "sentCurrency"
let localCurrencyKey = "localCurrency"
let budgetForThisMonthKey = "budgetForThisMonth"
let expensesKey = "expensesThisMonth"

//MARK: New keys.
//TODO: Delete old keys
let settingsKey             = "settingsKey"
let userNameKey             = "userNameKey"
let userImageKey            = "userImageKey"
let incomeAmountKey         = "incomeAmountKey"
let incomeCurrencyKey       = "incomeCurrencyKey"
let recurringPaymentKey     = "recurringPaymentKey"
let paymentDateKey          = "paymentDateKey"
let mustLastUntilKey        = "mustLastUntilKey"
let recurringExpensesKey    = "recurringExpensesKey"
let savingsKey              = "savingsKey"
let preferredCurrencyKey    = "preferredCurrencyKey"

let lastCheckedDateKey      = "lastCheckedDateKey"


// MARK: - bank comission for payments. Setting up as static for now, just because lazy. :P
let bankComission = 0.02

//MARK: For views.
let inset: CGFloat          = 16.0
let cornerRadius: CGFloat   = 15.0
