//
//  BudgetExport.swift
//  Budget
//
//  Created by Tudor Croitoru on 18.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class BudgetExportDocument: UIDocument {
    
    var budgetExport: BudgetExportData?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return budgetExport?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if  let budgetExportData = contents as? Data,
            let jsonDecodedBudget = try? JSONDecoder().decode(BudgetExportData.self, from: budgetExportData){
                budgetExport = jsonDecodedBudget
        }
    }
}
