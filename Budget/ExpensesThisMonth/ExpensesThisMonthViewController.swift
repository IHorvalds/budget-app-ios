//
//  ExpensesThisMonthViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 12.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class ExpensesThisMonthViewController: UITableViewController {
    
    var budgets: [BudgetForDay] = []
    var i = 1
    
    let dateFormatter = DateFormatter()
    
    @IBAction func openLeftMenu(_ sender: UIBarButtonItem) {
        panel?.openLeft(animated: true)
    }
    
    override func viewDidLoad() {
        dateFormatter.dateStyle = .long
        
        if budgets.isEmpty {
            budgets = (try? BudgetForDay.getBudgetsFromDefaults()) ?? []
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expensedetail" {
            if let destVC = segue.destination as? ExpenseDetailViewController {
                
                if  let cell    = sender as? UITableViewCell,
                    let index   = tableView.indexPath(for: cell) {
                    
                    let expense = budgets[index.section].expenses[index.row]
                    
                    destVC.purchaseTitle        = expense.title
                    destVC.datePurchasedBuffer  = expense.datePurchased
                    destVC.priceBuffer          = expense.price
                    destVC.currencyBuffer       = expense.currency.isoCode
                }
                
            }
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return budgets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgets[section].expenses.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(budgets[section].day)
        return dateFormatter.string(from: budgets[section].day)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkexpensecell") as! ExpenseCell?
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        
        let expense = budgets[indexPath.section].expenses[indexPath.row]
        cell?.textLabel?.text = expense.title
        numberFormatter.currencyCode = expense.currency.isoCode
        cell?.detailTextLabel?.text = numberFormatter.string(from: expense.price as NSNumber)
        
        

        return cell!
    }
}
