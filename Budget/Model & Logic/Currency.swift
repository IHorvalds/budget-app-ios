//
//  Currency.swift
//  Budget
//
//  Created by Tudor Croitoru on 08.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

//NOTE: We assume RON as base. x RON = x * rate <Currency>
let exchangeRates = ["RON": 1.00,
                    "DKK": 1.61,
                    "USD": 0.25,
                    "EUR": 0.22]

class Currency {
    let isoCode: String
    
    init(isoCode: String) {
        self.isoCode = isoCode
    }
    
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
