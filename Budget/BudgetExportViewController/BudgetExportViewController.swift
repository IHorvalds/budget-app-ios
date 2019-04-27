//
//  BudgetExportViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 18.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit
import MobileCoreServices

class BudgetExportViewController: UITableViewController {
    
    var document: BudgetExportDocument? //settings, budgets
    
    @IBAction func openLeftMenu(_ sender: UIBarButtonItem) {
        panel?.openLeft(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 50
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        document?.close(completionHandler: { (_) in
            print("Closed document")
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expensedetail" {
            if  let destVC      = segue.destination as? ExpenseDetailViewController {
                
                var expenses = [Expense]()
                document?.budgetExport?.budgets.forEach({ (b) in
                    expenses.append(contentsOf: b.expenses)
                })
                
                if  let s       = sender as? UITableViewCell,
                    let index   = tableView.indexPath(for: s) {
                    
                        destVC.purchaseTitle        = expenses[index.row].title
                        destVC.datePurchasedBuffer  = expenses[index.row].datePurchased
                        destVC.currencyBuffer       = expenses[index.row].currency.isoCode
                        destVC.priceBuffer          = expenses[index.row].price
                    
                }
                
//                if let expenses = document?.budgetExport?.expenses {
//                    destVC.purchaseTitle = expenses[(indexPath?.row)!].title
//                    destVC.datePurchasedBuffer = expenses[(indexPath?.row)!].datePurchased
//                    print(expenses[(indexPath?.row)!].price)
//                    destVC.priceBuffer = expenses[(indexPath?.row)!].price
//                }
            }
        }
        
    }

}

extension BudgetExportViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4 // payment date, must last until, amount + currency, savings
        case 1:
            return document?.budgetExport?.settings.recurringExpenses.count ?? 0
        case 2:
            var numberOfExpenses = 0
            document?.budgetExport?.budgets.forEach({ (b) in
                numberOfExpenses += b.expenses.count
            })
            return numberOfExpenses
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: // Payment Date
                cell = tableView.dequeueReusableCell(withIdentifier: "budgetdatecell")!
                if let paymentDate = document?.budgetExport?.settings.paymentDate {
                    cell.textLabel?.text = dateFormatter.string(from: paymentDate)
                }
            case 1: // Must Last until
                cell = tableView.dequeueReusableCell(withIdentifier: "budgetdatecell")!
                if let lastDate = document?.budgetExport?.settings.mustLastUntil {
                    cell.textLabel?.text = dateFormatter.string(from: lastDate)
                }
                
            case 2: // Income Amount in Currency
                cell = tableView.dequeueReusableCell(withIdentifier: "budgetdatecell")!
                if  let amount      = document?.budgetExport?.settings.incomeAmount,
                    let currency    = document?.budgetExport?.settings.incomeCurrency {
                    numberFormatter.currencyCode = currency
                    cell.textLabel?.text = numberFormatter.string(from: amount as NSNumber)
                }
            case 3: // Savings
                cell = tableView.dequeueReusableCell(withIdentifier: "budgetdatecell")!
                if  let amount      = document?.budgetExport?.settings.savingsTarget,
                    let currency    = document?.budgetExport?.settings.incomeCurrency {
                    numberFormatter.currencyCode = currency
                    cell.textLabel?.text = numberFormatter.string(from: amount as NSNumber)
                }
            default:
                return cell
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "budgetmoneycell")!
            if  document?.documentState == .normal,
                let recExpTitle = document?.budgetExport?.settings.recurringExpenses[indexPath.row].title,
                let recExpPrice = document?.budgetExport?.settings.recurringExpenses[indexPath.row].price,
                let recExpCur   = document?.budgetExport?.settings.recurringExpenses[indexPath.row].currency.isoCode {
                cell.textLabel?.text = recExpTitle
                numberFormatter.currencyCode = recExpCur
                cell.detailTextLabel?.text = numberFormatter.string(from: recExpPrice as NSNumber)
            }
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "checkexpensecell")!
            
            var expenses = [Expense]()
            document?.budgetExport?.budgets.forEach({ (b) in
                expenses.append(contentsOf: b.expenses)
            })
            
            if  document?.documentState == .normal {
                let recExpTitle = expenses[indexPath.row].title
                let recExpPrice = expenses[indexPath.row].price
                let recExpCur   = expenses[indexPath.row].currency.isoCode
                cell.textLabel?.text = recExpTitle
                numberFormatter.currencyCode = recExpCur
                cell.detailTextLabel?.text = numberFormatter.string(from: recExpPrice as NSNumber)
            }
        default:
            return cell
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Period details"
        case 1:
            return "Scheduled expenses"
        case 2:
            return "Expenses"
        default:
            return nil
        }
    }
}
