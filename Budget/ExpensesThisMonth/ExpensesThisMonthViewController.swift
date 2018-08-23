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
    var budgets: [BudgetForDay] = []
    var i = 1
    var canEdit = false
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        canEdit = !canEdit
        if canEdit {
            for cell in tableView.visibleCells {
                cell.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            }
            
            sender.title = "Done"
            sender.tintColor = #colorLiteral(red: 0.1729659908, green: 0.5823032236, blue: 1, alpha: 1)
        } else {
            for cell in tableView.visibleCells {
                cell.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
                cell.textLabel?.textColor = .white
                cell.detailTextLabel?.textColor = .white
            }
            
            sender.title = "Edit"
            if expenses.isEmpty {
                sender.isEnabled = false
            } else {
                sender.isEnabled = true
                sender.tintColor = #colorLiteral(red: 0.9764705882, green: 0.3294117647, blue: 0.3333333333, alpha: 1)
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editButton.isEnabled = !expenses.isEmpty
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expensedetail" {
            if let destVC = segue.destination as? ExpenseDetailViewController {
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

    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
        if canEdit == true {
            return true
        } else {
            return false
        }
     }
    
    // MARK: - Look here for deleting expenses

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let removedExpense = self.expenses.remove(at: indexPath.row)
            saveExpensesToDisk()
            let today = Date()
            let day = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: today)
            let dayOfToday = Calendar.current.date(from: day)
            let budget = budgets.first(where: {$0.day == (dayOfToday!)})
            if let budgetForToday = budget {
                budgetForToday.totalUsableAmount += removedExpense.price //TODO: get this budget back to budgetviewcontroller
                budgets[budgets.index(of: budgetForToday)!] = budgetForToday
                defaults.set(archiveBudgetsAsData(budgets: budgets), forKey: budgetForThisMonthKey)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func archiveExpenses(expenses: [Expense]) -> Data {
        let archivedExpenses = NSKeyedArchiver.archivedData(withRootObject: expenses)
        return archivedExpenses
    }
    
    func saveExpensesToDisk() {
        defaults.set(archiveExpenses(expenses: self.expenses), forKey: expensesKey)
    }


}
