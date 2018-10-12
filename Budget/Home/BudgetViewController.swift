//
//  ViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 04.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit
import UserNotifications
import MobileCoreServices

class BudgetViewController: UITableViewController, UIDocumentPickerDelegate {
    
    //@IBOutlet weak var navBar: UINavigationItem!
    var expenses: [Expense] = []
    var quantityThisMonth: Double?
    let numberFormatter = NumberFormatter()
    
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
            if  let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
                let budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay] {
                destVC.budgets = budgets
            }
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
            return 3
        } else {
            let today = Date()
            let day = Calendar.current.dateComponents([.year, .month, .day], from: today)
            let dayOfToday = Calendar.current.date(from: day)!
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
        numberFormatter.numberStyle = .currency
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "overviewcell") as! OverViewTableViewCell?
                cell?.delegate = self
                if let moneyLeftThisMonthLabel = moneyLeft {
                    numberFormatter.currencyCode = (defaults.value(forKey: localCurrencyKey) as! String)
                    if let formattedMoneyLeft = numberFormatter.string(from: moneyLeftThisMonthLabel as NSNumber) {
                        cell?.moneyLeftThisMonth.setTitle("Money left: " + formattedMoneyLeft, for: .normal)
                    } else {
                        cell?.moneyLeftThisMonth.setTitle("Money left: ???", for: .normal)
                    }
                } else {
                    cell?.moneyLeftThisMonth.setTitle("Money left: ???", for: .normal)
                }
                if let quantity = quantityThisMonth {
                    if let currency = defaults.value(forKey: localCurrencyKey) as? String {
                        numberFormatter.currencyCode = currency
                        if let budgetThisMonth = numberFormatter.string(from: quantity as NSNumber) {
                            cell?.budgetThisMonth.text = "This month: " + budgetThisMonth
                        } else {
                            cell?.budgetThisMonth.text = "This month: ???"
                        }
                    } else {
                        cell?.budgetThisMonth.text = "This month: ???"
                    }
                } else {
                    cell?.budgetThisMonth.text = "This month: ???"
                }
                cell?.isInOrOverBudget.text = isWithinBudget()
                cell?.layoutSubviews()
                return cell!
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "transparentcell")
                
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dayreporttotalcell")
                if let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
                    let budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay] {
                    let today = Date()
                    let day = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: today)
                    let dayOfToday = Calendar.current.date(from: day)
                    for budgeteer in budgets { ///for debugging
                        print("The total for \(budgeteer.day) in \(budgeteer.totalUsableAmount)")
                    }
                    let budget = budgets.first(where: {$0.day == (dayOfToday!)})
                    if let dayAmount = budget?.totalUsableAmount {
                        numberFormatter.currencyCode = (defaults.value(forKey: localCurrencyKey) as! String)
                        if let formattedDayAmount = numberFormatter.string(from: dayAmount as NSNumber) {
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
            let dayOfToday = Calendar.current.date(from: day)!
            let todayExpenses = self.expenses.filter({$0.datePurchased == (dayOfToday)})
            
            if indexPath.row == todayExpenses.count {
                cell = tableView.dequeueReusableCell(withIdentifier: "addexpensecell") as! ExpenseCell?
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "expensecell") as! ExpenseCell?
                cell?.textLabel?.text = todayExpenses[indexPath.row].title
                if let localCurr = defaults.value(forKey: localCurrencyKey) as? String {
                    numberFormatter.currencyCode = localCurr
                    cell?.detailTextLabel?.text = numberFormatter.string(from: todayExpenses[indexPath.row].price as NSNumber)
                } else {
                    cell?.detailTextLabel?.text = String(todayExpenses[indexPath.row].price)
                }
                
            }
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let today = Date()
        let day = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: today)
        let dayOfToday = Calendar.current.date(from: day)
        let todayExpenses = expenses.filter({$0.datePurchased == dayOfToday})
        if indexPath.section == 1, indexPath.row == (todayExpenses.count) {
            print("pressed")
            print(expenses)
            self.tableView.deselectRow(at: indexPath, animated: true)
            popUpForAddingExpense()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let today = Date()
        let day = Calendar.current.dateComponents([.year, .month, .day], from: today)
        let dayOfToday = Calendar.current.date(from: day)!
        let todayExpenses = self.expenses.filter({$0.datePurchased == (dayOfToday)})
        if indexPath.section == 1, indexPath.row != todayExpenses.count {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let today = Date()
            let day = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: today)
            let dayOfToday = Calendar.current.date(from: day)
            var todayExpenses = expenses.filter({$0.datePurchased == dayOfToday})
            let removedExpense = todayExpenses.remove(at: indexPath.row)
            expenses.remove(at: expenses.index(of: removedExpense)!)
            saveExpensesToDisk()
            if  let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
                var budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay] {
                let budget = budgets.first(where: {$0.day == (dayOfToday!)})
                if let budgetForToday = budget {
                    budgetForToday.totalUsableAmount += removedExpense.price
                    budgets[budgets.index(of: budgetForToday)!] = budgetForToday
                    defaults.set(archiveBudgetsAsData(budgets: budgets), forKey: budgetForThisMonthKey)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()
                }
            }
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
        
        if  let curr = defaults.value(forKey: sentCurrencyKey) as? String,
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
        print("money left")
    }
}

extension BudgetViewController {
    func popUpForAddingExpense() {
        let inputAlert = UIAlertController.init(title: "Add an expense", message: "What did you buy and how much did it cost?", preferredStyle: UIAlertController.Style.alert)
        
        inputAlert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Give it a name..."
            textField.enablesReturnKeyAutomatically = true
            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
            textField.spellCheckingType = UITextSpellCheckingType.yes
        })
        inputAlert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "How much was it? (Without comission)"
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
                                                  price: Double(inputAlert.textFields![1].text!)!*(1.0 + bankComission)))
                if let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
                    var budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay],
                    !self.expenses.isEmpty {
                    let today = Date()
                    let day = Calendar.current.dateComponents([.year, .month, .day], from: today)
                    let dayOfToday = Calendar.current.date(from: day)!
                    let budget = budgets.first(where: {$0.day == (dayOfToday)})
                    if (budget?.totalUsableAmount) != nil {
                        if let expense = self.expenses.last {
                            budget?.updateTotalUsableAmount(expense: expense)
                        }
                        budgets[budgets.index(of: budget!)!] = budget!
                        defaults.set(archiveBudgetsAsData(budgets: budgets), forKey: budgetForThisMonthKey)
                    }
                    
                }
                self.tableView.reloadData()
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
