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
    //var initialColors: [Any]?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        canEdit = !canEdit
        
        if canEdit {
            sender.title = "Done"
            sender.tintColor = #colorLiteral(red: 0.1729659908, green: 0.5823032236, blue: 1, alpha: 1)
        } else {
            sender.title = "Edit"
            if expenses.isEmpty {
                sender.isEnabled = false
            } else {
                sender.isEnabled = true
                sender.tintColor = #colorLiteral(red: 0.5803921569, green: 0.09019607843, blue: 0.3176470588, alpha: 1)
            }
        }
        
        tableView.reloadData()

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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkexpensecell") as! ExpenseCell?
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        if !canEdit {
            cell?.firstColor = UIColor(red:0.17, green:0.38, blue:0.64, alpha:1.0)
            cell?.secondColor = UIColor(red:0.65, green:0.92, blue:1.00, alpha:1.0)
            cell?.textLabel?.textColor = .white
            //cell?.detailTextLabel?.textColor = .white
        } else {
            cell?.firstColor = UIColor(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            cell?.secondColor = UIColor.white
            cell?.textLabel?.textColor = .black
            //cell?.detailTextLabel?.textColor = .black
        }
        if let localCurrency = defaults.value(forKey: localCurrencyKey) as? String {
            numberFormatter.currencyCode = localCurrency
        } else {
            numberFormatter.currencyCode = " "
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
