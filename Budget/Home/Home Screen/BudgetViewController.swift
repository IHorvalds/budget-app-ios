//
//  ViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 04.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit
import MobileCoreServices
import NotificationCenter

class BudgetViewController: UITableViewController {
    
    let numberFormatter = NumberFormatter()
    var budget: BudgetForDay?
    
    var settings: Settings = (try? Settings.getSettingsFromDefaults()) ?? Settings.standardSettings
    var budgets = [BudgetForDay]()
    
    
    //MARK: ExpenseInputDelegate
    var date: Date?
    var expense: Expense?
    
    @IBAction func showLeftPanel(_ sender: UIBarButtonItem) {
        panel?.openLeft(animated: true)
    }
    
    @IBAction func exportRightNow(_ sender: UIBarButtonItem) {
        
        let alertForExport = UIAlertController(title: "Do you wish to export your current period?", message: nil, preferredStyle: .alert)
        
        alertForExport.addAction(.init(title: "Export and keep information", style: .default, handler: { (_) in
            
            let budgetData = BudgetExportData(budgets: self.budgets, settings: self.settings)
            do {
                try budgetData.exportCurrentPeriod()
                
            } catch let error {
                let alert = UIAlertController(title: "Error exporting current period", message: "This is the error thrown: \(error).", preferredStyle: .alert)
                
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        alertForExport.addAction(.init(title: "Export and reset information", style: .destructive, handler: { (_) in
        
            let budgetData = BudgetExportData(budgets: self.budgets, settings: self.settings)
            do {
                try budgetData.exportCurrentPeriod()
                
                self.settings = Settings.standardSettings
                
            } catch let error {
                let alert = UIAlertController(title: "Error exporting current period", message: "This is the error thrown: \(error).", preferredStyle: .alert)
                
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        alertForExport.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertForExport, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        newDay()
        budget = budgets.first(where: {Date.areSameDay(date1: $0.day, date2: Date())})
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(newDay),
                                       name: NSNotification.Name.NSCalendarDayChanged,
                                       object: nil)
    }
    
    @objc func newDay() {
        
        budgets = BudgetForDay.newDayExport(settings: &settings)
        budgets = BudgetForDay.settingsDidChange(budgets: budgets, settings: settings)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let collectionViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CollectionTableViewCell {
            let budgetsCount = collectionViewCell.budgets.count
            let count = ( budgetsCount != 0) ? budgetsCount-1 : 0
            collectionViewCell.collectionView.scrollToItem(at: IndexPath(row: count, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    
    
    //MARK: Table view stuff
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //MARK: - Name the sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Overview"
        case 2:
            return "Today"
        default:
            return nil
        }
    }
    
    //MARK: - How many rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return (budget?.expenses.count ?? 0) + 1
        }
    }
    
    //MARK: - Size the cells appropriately
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 0 {
            return 280
        } else {
            return 50
        }
    }
    
    //MARK: - display the cells of the main screen
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        numberFormatter.numberStyle = .currency
        let fontSize: CGFloat = 18.0
        let cellTextFont = UIFont.systemFont(ofSize: fontSize, weight: .light)
        let fontDescriptor = cellTextFont.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitItalic)
        
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "overviewcell") as! CollectionTableViewCell
            (cell as! CollectionTableViewCell).collectionDelegate = self
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "thismonthcell") as! TodayAvailableCell
            cell.textLabel?.font        = cellTextFont
            cell.detailTextLabel?.font  = UIFont(descriptor: fontDescriptor!, size: fontSize)
            
            cell.textLabel?.text        = "Left this month:"
            
            if let lastBudget = budgets.last {
                numberFormatter.currencyCode    = lastBudget.currency
                cell.detailTextLabel?.text      = numberFormatter.string(from: lastBudget.totalUsableAmount as NSNumber)
            }
            
        case 2:
            if indexPath.row == (budget?.expenses.count ?? 0) {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "addexpensecell") as! ExpenseCell
                
            } else {
                
                if  let budget = budget {
                    let expenses = budget.expenses
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "expensecell") as! ExpenseCell
                    cell.textLabel?.font        = cellTextFont
                    cell.detailTextLabel?.font  = UIFont(descriptor: fontDescriptor!, size: fontSize)
                    
                    numberFormatter.currencyCode    = expenses[indexPath.row].currency.isoCode
                    cell.textLabel?.text            = expenses[indexPath.row].title
                    cell.detailTextLabel?.text      = numberFormatter.string(from: expenses[indexPath.row].price as NSNumber)
                }
            }
        default:
            break
        }
    
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2, indexPath.row == budget?.expenses.count {
            let storyboard      = UIStoryboard(name: "ExpenseInputViewController", bundle: nil)
            let inputVC         = storyboard.instantiateInitialViewController() as! ExpenseInputViewController
            inputVC.delegate    = self
            self.date           = Date()
            
            inputVC._initialCurrencyString = settings.preferredCurrency
            present(inputVC, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let today = Date()
        let todayExpenses = budget?.expenses.filter({Date.areSameDay(date1: $0.datePurchased, date2: today)})
        if indexPath.section == 2, indexPath.row != todayExpenses?.count {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let expense = budget?.expenses[indexPath.row] {
                BudgetForDay.removeExpense(expense: expense, budgets: budgets)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections(IndexSet(integersIn: 0...1), with: .none)
                
                
                if let collectionViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CollectionTableViewCell {
                    let budgetsCount = collectionViewCell.budgets.count
                    let count = ( budgetsCount != 0) ? budgetsCount-1 : 0
                    collectionViewCell.collectionView.scrollToItem(at: IndexPath(row: count, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
    }
}

extension BudgetViewController: CollectionDelegate {
    func showBudgetCollectionDelegate(budget: BudgetForDay?) {
        let storyboard = UIStoryboard(name: "ExpensesThisMonthViewController", bundle: nil)
        let exp = storyboard.instantiateInitialViewController() as! ExpensesThisMonthViewController
        if  let budget = budget {
            exp.budgets = [budget]
            self.show(exp, sender: nil)
        }
    }
}

extension BudgetViewController: ExpenseInputDelegate {
    
    func pressedOKButton(_ view: InputView, ok button: AlertButton, input object: InputObject?) {
        if  let object = object,
            object.isComplete() {
            
            let expense = Expense(title: object.itemName,
                                  price: object.itemPrice,
                                  currency: object.currency.isoCode,
                                  datePurchased: Date())
            BudgetForDay.updateTotalUsableAmount(expense: expense, budgets: budgets)
            tableView.reloadSections(IndexSet(arrayLiteral: 0, 2), with: .top)
            tableView.reloadSections(IndexSet(integer: 1), with: .none)
            if let collectionViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CollectionTableViewCell {
                let budgetsCount = collectionViewCell.budgets.count
                let count = ( budgetsCount != 0) ? budgetsCount-1 : 0
                collectionViewCell.collectionView.scrollToItem(at: IndexPath(row: count, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        
    }
    
    func pressedCancelButton(_ view: InputView, cancel button: AlertButton, input object: InputObject?) {
        
    }
    
    
}
