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
//var exchangeRates: [String: Double]  = ["RON": 1.00,
//                                        "DKK": 1.61,
//                                        "USD": 0.25,
//                                        "EUR": 0.22,
//                                        "GBP": 0.19]

struct RatesFromAPI {
    
    func getRatesFromAPI() {
        //get rates from api
        //https://api.exchangeratesapi.io/latest
        
        var calendar        = Calendar(identifier: .gregorian)
        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        
        let today = Date()
        
        if  let lastDate = defaults.value(forKey: lastCheckedExchangeDateKey) as? Date {
            if calendar.compare(lastDate, to: today, toGranularity: .day) == .orderedAscending && !Date.areSameDay(date1: today, date2: lastDate) {
                print("Asking the cats of the internets for exchange rates...")
                
                let url = URL(string: "https://api.exchangeratesapi.io/latest")!
                let session = URLSession.shared
                _ = session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if  response != nil,
                        let data = data,
                        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-dd"
                        
                        if  var exchange = json["rates"] as? [String: Double],
                            let base    = json["base"] as? String,
                            let dateString = json["date"] as? String,
                            let date    = dateFormatter.date(from: dateString) {
                            
                            defaults.set(date, forKey: lastCheckedExchangeDateKey)
                            exchange[base] = 1.00
                            
                            //MARK: Updating the exchangeRates.
                            exchangeRates = exchange
                            
                            //MARK: Caching in defaults. Can't think of an excuse to use NSCache here.
                            defaults.set(exchangeRates, forKey: cachedExchangeRatesKey)
                        }
                        
                    } else {
                        print(error as Any)
                    }
                }).resume()
            } else { //Here, today and lastDate are the same day. Effectively, we're just opening the app again later in the day. Hopefully someone will do that. Heh
                print("Already asked today. Here are the exchange rates!")
                if let exchanges = defaults.value(forKey: cachedExchangeRatesKey) as? [String : Double] {
                    exchangeRates = exchanges
                }
            }
        }
    }
}


struct Currency: Codable, Equatable {
    let isoCode: String
    
    func convert(toCurrency desiredCurrency: Currency, amount: Double) -> Double? {
        if let rate = exchangeRates[self.isoCode] {
            let amountInEUR = amount/rate
            if let rateTwo = exchangeRates[desiredCurrency.isoCode] {
                return amountInEUR * rateTwo
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
}
