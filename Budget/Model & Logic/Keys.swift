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
//
//// MARK: OLD!!!! UserDefaults keys
//let dateReceivedKey = "dateReceived"
//let lastsUntilKey = "lastsUntil"
//let notificationsAccessKey = "notificationAccess"
//let rentDueDateKey = "rentDueDate"
//let budgetKey = "moneyReceived"
//let rentAmountKey = "rentAmount"
//let sentCurrencyKey = "sentCurrency"
//let localCurrencyKey = "localCurrency"
//let budgetForThisMonthKey = "budgetForThisMonth"
//let expensesKey = "expensesThisMonth"

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

let lastUsedCurrencyKey      = "lastUsedCurrencyKey"
let usedDifferentCurrencyKey = "usedDifferentCurrencyKey"
let lastCheckedExchangeDateKey   = "lastCheckedExchangeDateKey"
let cachedExchangeRatesKey      = "cachedExchangeRates"


// TODO: Add this to the Settings class
let bankComission = 0.02

//MARK: For views.
let inset: CGFloat          = 16.0
let cornerRadius: CGFloat   = 15.0

//MARK: initial exchange rates. On 2019-03-15
var exchangeRates: [String: Double] = [
    "MXN": 21.7827,
    "AUD": 1.5988,
    "HKD": 8.8766,
    "RON": 4.7565,
    "HRK": 7.419,
    "CHF": 1.136,
    "IDR": 16143.3,
    "CAD": 1.5118,
    "USD": 1.1308,
    "ZAR": 16.3782,
    "JPY": 126.16,
    "BRL": 4.3576,
    "HUF": 314.35,
    "CZK": 25.668,
    "NOK": 9.688,
    "INR": 78.074,
    "PLN": 4.3049,
    "ISK": 132.9,
    "PHP": 59.491,
    "SEK": 10.4964,
    "ILS": 4.0708,
    "GBP": 0.85415,
    "SGD": 1.5313,
    "CNY": 7.5922,
    "TRY": 6.1858,
    "MYR": 4.6171,
    "RUB": 73.9233,
    "NZD": 1.6532,
    "KRW": 1284.65,
    "THB": 35.846,
    "BGN": 1.9558,
    "DKK": 7.4634,
    "EUR": 1.00
]
