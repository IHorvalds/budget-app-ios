//
//  ExpensesThisMonthViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 12.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class ExpensesThisMonthViewController: UITableViewController {
    
    var expenses: [Expense] = []
    var i = 1
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //TODO: if there are any changes to expenses array, write them to disk
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expensedetail" {
            if let destVC = segue.destination as? ExpenseDetailViewController {
                print("aye 2")
                let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
                destVC.purchaseTitle = expenses[(indexPath?.row)!].title
                destVC.datePurchasedBuffer = expenses[(indexPath?.row)!].datePurchased
                destVC.priceBuffer = expenses[(indexPath?.row)!].price
                
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //        MARK: - useful when we're going to sort the expenses by month
//        print (self.expenses.count)
//        if self.expenses.count > 0 {
//            var bufferDate: Int
//            let calendar = Calendar.current
//            bufferDate = calendar.component(.month, from: expenses[0].datePurchased)
//            for expense in expenses {
//                if calendar.component(.month, from: expense.datePurchased) != bufferDate {
//                    i += 1
//                    bufferDate = calendar.component(.month, from: expense.datePurchased)
//                }
//            }
//
//            return i
//        }
//        return 0
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    //MARK: - Also useful when we're going to sort the expenses by month
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if expenses.count > 0 {
//            var months: [Int] = []
//            var bufferDate = Calendar.current.component(.month, from: expenses[0].datePurchased)
//            months.append(bufferDate)
//            for expense in expenses {
//                if bufferDate != Calendar.current.component(.month, from: expense.datePurchased) {
//                    months.append(Calendar.current.component(.month, from: expense.datePurchased))
//                    bufferDate = Calendar.current.component(.month, from: expense.datePurchased)
//                }
//            }
//
//            return Calendar.current.monthSymbols[months[section] - 1]
//        }
//        return nil
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkexpensecell")
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        if let localCurrency = defaults.value(forKey: localCurrencyKey) as? String {
            numberFormatter.currencyCode = localCurrency
        } else {
            numberFormatter.currencyCode = ""
        }
        
        
        // Configure the cell...
        cell?.textLabel?.text = expenses[indexPath.row].title
        cell?.detailTextLabel?.text = numberFormatter.string(from: expenses[indexPath.row].price as NSNumber)


        return cell!
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    // MARK: - Look here for deleting expenses
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
