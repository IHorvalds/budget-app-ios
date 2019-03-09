//
//  Currency.swift
//  Budget
//
//  Created by Tudor Croitoru on 08.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

//TODO: get data from https://exchangeratesapi.io/
//TODO: Don't forget to cache it.
let exchangeRates = ["RON": 1.00,
                    "DKK": 1.61,
                    "USD": 0.25,
                    "EUR": 0.22,
                    "GBP": 0.19]

struct Currency: Codable {
    let isoCode: String
    
    func convert(toCurrency desiredCurrency: Currency, amount: Double) -> Double? {
        if let rate = exchangeRates[self.isoCode] {
            let amountInRON = amount/rate
            if let rateTwo = exchangeRates[desiredCurrency.isoCode] {
                return amountInRON * rateTwo
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
}
