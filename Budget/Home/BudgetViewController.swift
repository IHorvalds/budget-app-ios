//
//  ViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 04.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit
import UserNotifications

class BudgetViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    var expenses: [Expense] = []
    var quantityThisMonth: Double?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let expensesThisMonthData = defaults.value(forKey: expensesKey) as? Data {
            let expensesThisMonth = unarchiveExpenses(expensesData: expensesThisMonthData)
            self.expenses = expensesThisMonth
        }
        
        endOfDayExport()
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "seguetoexpenses",
            let destVC = segue.destination as? ExpensesThisMonthViewController {
            destVC.expenses = self.expenses
        }
    }
}

extension BudgetViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //MARK: - Name the sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != 0 {
            return "Today"
        }
        return "Overview"
    }
    
    //MARK: - How many rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        } else {
            let today = Date()
            let day = Calendar.current.dateComponents([.year, .month, .day], from: today)
            let dayOfToday = Calendar.current.date(from: day)! + TimeInterval(86400)
            let todayExpenses = self.expenses.filter({$0.datePurchased == (dayOfToday)})
            return todayExpenses.count + 1
        }
    }
    
    //MARK: - Size the cells appropriately
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 0 {
            return 250
        } else {
            return 50
        }
    }
    
    //MARK: - display the cells of the main screen
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "overviewcell") as! OverViewTableViewCell?
                cell?.delegate = self
                if let moneyLeftThisMonthLabel = moneyLeft {
                    let currencyFormatter = NumberFormatter()
                    currencyFormatter.numberStyle = .currency
                    currencyFormatter.currencyCode = (defaults.value(forKey: localCurrencyKey) as! String)
                    if let formattedMoneyLeft = currencyFormatter.string(from: moneyLeftThisMonthLabel as NSNumber) {
                        cell?.moneyLeftThisMonth.setTitle("Money left: " + formattedMoneyLeft, for: .normal)
                    } else {
                        cell?.moneyLeftThisMonth.setTitle("Money left: ???", for: .normal)
                    }
                } else {
                    cell?.moneyLeftThisMonth.setTitle("Money left: ???", for: .normal)
                }
                if let quantity = quantityThisMonth {
                    if let currency = defaults.value(forKey: localCurrencyKey) as? String {
                        let currencyFormatter = NumberFormatter()
                        currencyFormatter.numberStyle = .currency
                        currencyFormatter.currencyCode = currency
                        if let budgetThisMonth = currencyFormatter.string(from: quantity as NSNumber) {
                            cell?.budgetThisMonth.text = "Budget this month: " + budgetThisMonth
                        } else {
                            cell?.budgetThisMonth.text = "Budget this month: ???"
                        }
                    } else {
                        cell?.budgetThisMonth.text = "Budget this month: ???"
                    }
                } else {
                    cell?.budgetThisMonth.text = "Budget this month: ???"
                }
                
                //TODO: load salaryDay from UserDefaults
                //            if isWithinBudget(startingFrom: salaryDay) {
                //                cell?.isInOrOverBudget.text = "In Budget"
                //            } else {
                //                cell?.isInOrOverBudget.text = "Over budget"
                //                cell?.isInOrOverBudget.textColor = #colorLiteral(red: 1, green: 0.3300999652, blue: 0.299975277, alpha: 1)
                //            }
                cell?.isInOrOverBudget.text = isWithinBudget()
                cell?.layoutSubviews()
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dayreporttotalcell")
                if let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
                    let budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay] {
                    let today = Date()
                    let day = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: today)
                    let dayOfToday = Calendar.current.date(from: day)
                    let budget = budgets.first(where: {$0.day == (dayOfToday! + TimeInterval(86400))})
                    if let dayAmount = budget?.totalUsableAmount {
                        let currencyFormatter = NumberFormatter()
                        currencyFormatter.numberStyle = .currency
                        currencyFormatter.currencyCode = (defaults.value(forKey: localCurrencyKey) as! String)
                        if let formattedDayAmount = currencyFormatter.string(from: dayAmount as NSNumber) {
                            cell?.detailTextLabel?.text = formattedDayAmount
                        } else {
                            cell?.detailTextLabel?.text = "???"
                        }
                        
                    } else {
                        cell?.detailTextLabel?.text = "???"
                    }
                } else {
                    cell?.detailTextLabel?.text = "???"
                }
                
                return cell!
                
            }
        } else {
            
            let cell: UITableViewCell?
            let today = Date()
            let day = Calendar.current.dateComponents([.year, .month, .day], from: today)
            let dayOfToday = Calendar.current.date(from: day)! + TimeInterval(86400)
            let todayExpenses = self.expenses.filter({$0.datePurchased == (dayOfToday)})
            
            if indexPath.row == todayExpenses.count {
                cell = tableView.dequeueReusableCell(withIdentifier: "addexpensecell")
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "expensecell")

                cell?.textLabel?.text = todayExpenses[indexPath.row].title
                if let localCurr = defaults.value(forKey: localCurrencyKey) as? String {
                    cell?.detailTextLabel?.text = localCurr + String(todayExpenses[indexPath.row].price)
                } else {
                    cell?.detailTextLabel?.text = String(todayExpenses[indexPath.row].price)
                }
                
            }
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == (expenses.count) {
            print("pressed")
            print(expenses)
            self.tableView.deselectRow(at: indexPath, animated: true)
            popUpForAddingExpense()
        }
    }
}

extension BudgetViewController: OverviewTableViewCellDelegate {
    var moneyLeft: Double? {
        
        var expensesTotal: Double {
            var expenseTotal = 0.00
            for i in expenses {
                expenseTotal += i.price
            }
            return expenseTotal
        }
        
        if let curr = defaults.value(forKey: sentCurrencyKey) as? String,
            let curr2 = defaults.value(forKey: localCurrencyKey) as? String,
            let totalAmount = defaults.value(forKey: budgetKey) as? String,
            let rentAmount = defaults.value(forKey: rentAmountKey) as? String {
            let initialCurr = Currency.init(isoCode: curr)
            let localCurr = Currency.init(isoCode: curr2)
            if let quantity = initialCurr.convert(toCurrency: localCurr, amount: Double(totalAmount)!) {
                let quantityAfterRent = quantity - Double(rentAmount)!
                quantityThisMonth = quantity //use this to set the budget label in the first cell
                return quantityAfterRent - expensesTotal
            }
        }
        return nil
    }
    
    func didTapMoneyLeft() {
        print("money left") //TODO: segue to ExpensesThisMonthViewController
    }
}

extension BudgetViewController {
    func popUpForAddingExpense() {
        let inputAlert = UIAlertController.init(title: "Add an expense", message: "What did you buy and how much did it cost?", preferredStyle: UIAlertControllerStyle.alert)
        
        inputAlert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Give it a name..."
            textField.enablesReturnKeyAutomatically = true
        })
        inputAlert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "How much was it?"
            textField.enablesReturnKeyAutomatically = true
            textField.keyboardType = UIKeyboardType.decimalPad
        })
        inputAlert.addAction(.init(title: "Cancel", style: .destructive, handler: { (_: UIAlertAction!) in
            inputAlert.textFields![0].text = ""
            inputAlert.textFields![1].text = ""
            print("lol")
        }))
        inputAlert.addAction(.init(title: "Done", style: .default, handler: {(_: UIAlertAction!) in
            if inputAlert.textFields![0].hasText,
            inputAlert.textFields![1].hasText {
                self.expenses.append(Expense.init(title: inputAlert.textFields![0].text!,
                                             price: Double(inputAlert.textFields![1].text!)!))
            if let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
            var budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay],
            !self.expenses.isEmpty {
            let today = Date()
            let day = Calendar.current.dateComponents([.year, .month, .day], from: today)
            let dayOfToday = Calendar.current.date(from: day)! + TimeInterval(86400)
            let budget = budgets.first(where: {$0.day == (dayOfToday)})
            if let dayAmount = budget?.totalUsableAmount {
            let todayExpenses = self.expenses.filter({$0.datePurchased == (dayOfToday)})
            var todayAmountSpent: Double {
            var intermediaryTotal = 0.0
            for expense in todayExpenses {
            intermediaryTotal += expense.price
            }
            
            return intermediaryTotal
            }
            for expense in todayExpenses {
            budget?.updateTotalUsableAmount(expense: expense)
            }
            budgets[budgets.index(of: budget!)!] = budget!
            defaults.set(archiveBudgetsAsData(budgets: budgets), forKey: budgetForThisMonthKey)
            }}
                self.tableView.reloadData()
                print(self.expenses)
                self.saveExpensesToDisk()
            } else {
                let alert = UIAlertController.init(title: "Oops!", message: "Please add all the necessary information about your purchase. Thank you!", preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: { (_: UIAlertAction) in
                
            }))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        self.present(inputAlert, animated: true, completion: nil)
    }
    
    func archiveExpenses(expenses: [Expense]) -> Data {
        let archivedExpenses = NSKeyedArchiver.archivedData(withRootObject: expenses)
        return archivedExpenses
    }
    
    func unarchiveExpenses(expensesData: Data) -> [Expense] {
        let unarchivedExpenses = NSKeyedUnarchiver.unarchiveObject(with: expensesData) as! [Expense]
        return unarchivedExpenses
    }
    
    func saveExpensesToDisk() {
        defaults.set(archiveExpenses(expenses: self.expenses), forKey: expensesKey)
    }
}
