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

    let budgets: [BudgetForDay]
    let settings: Settings
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func exportCurrentPeriod() throws {
        if  let initialDate = self.settings.paymentDate,
            let finalDate   = self.settings.mustLastUntil {
            
            let calendar            = Calendar.autoupdatingCurrent
            let initialMonthIndex   = calendar.component(.month, from: initialDate)
            let finalMonthIndex     = calendar.component(.month, from: finalDate)
            let initialMonthString  = calendar.standaloneMonthSymbols[initialMonthIndex]
            let finalMonthString    = calendar.standaloneMonthSymbols[finalMonthIndex]
            
            do {
                let savePath = try FileManager.default.url(for: .documentDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true).appendingPathComponent(initialMonthString + "-" + finalMonthString + ".bdg")
                
                let budgetDocument = BudgetExportDocument(fileURL: savePath)
                budgetDocument.budgetExport = self
                if !FileManager.default.fileExists(atPath: savePath.path) {
                    budgetDocument.save(to: savePath, for: .forCreating, completionHandler: nil)
                }
            } catch let error {
                throw error
            }
            
        }
    }
}
