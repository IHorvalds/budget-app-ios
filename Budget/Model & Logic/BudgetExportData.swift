//
//  ExportData.swift
//  Budget
//
//  Created by Tudor Croitoru on 17.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

struct BudgetExportData: Codable { //this will be exported with the name "<month of dateReceived>-<month of lastDay>.json"
    //TODO: Make app conform to UIDocument
    let expenses: [Expense]?
    let dateReceived: String
    let lastDay: String
    let sentCurrency: String
    let localCurrency: String
    let totalSent: Double
    let rentAmount: Double
    let amountSpent: Double
    let amountRemaining: Double
    
    init(expenses: [Expense]? = nil, dateReceived: String, lastDay: String, totalSent: Double, rentAmount: Double, amountSpent: Double, amountRemaining: Double, sentCurrency: String, localCurrency: String) {
        self.expenses           = expenses
        self.dateReceived       = dateReceived
        self.lastDay            = lastDay
        self.sentCurrency       = sentCurrency
        self.localCurrency      = localCurrency
        self.totalSent          = totalSent
        self.rentAmount         = rentAmount
        self.amountSpent        = amountSpent
        self.amountRemaining    = amountRemaining
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
}
