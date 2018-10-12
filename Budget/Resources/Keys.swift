//
//  Keys.swift
//  Budget
//
//  Created by Tudor Croitoru on 09.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

let defaults = UserDefaults.standard

// MARK: - UserDefaults keys
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

// MARK: - bank comission for payments. Setting up as static for now, just because lazy. :P
let bankComission = 0.02
