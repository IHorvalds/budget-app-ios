//
//  Saving.swift
//  Budget
//
//  Created by Tudor Croitoru on 06.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

class Saving: Codable {
    let title: String
    var amount: Double
    let dateSaved = Date()
    
    init(amount: Double){
        let monthSymbol = Calendar.autoupdatingCurrent.monthSymbols
        let currentMonth = Calendar.autoupdatingCurrent.component(Calendar.Component.month, from: dateSaved) - 1
        
        self.amount = amount
        self.title = monthSymbol[currentMonth]
    }
}
