//
//  RecurringExpenseViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 12/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import KDCalendar

class RecurringExpenseViewController: UITableViewController, CalendarViewDelegate {
    //MARK: ExpenseViewControllerDelegate
    var date: Date? = Date()
    var inputObject: InputObject?
    var expense: Expense?
    
    //Mark: not for the delegate
    var expenseRepresented: RecurringExpense?
    var isBeingEdited: Bool = false
    var calendar            = Calendar(identifier: .gregorian)
    
    var settings: Settings?
    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        expenseRepresented?.turnNotifications(onOrOff: sender.isOn)
    }
    
    
    @IBAction func saveExpense(_ sender: UIBarButtonItem) {
        //In case the user pressed Cancel and then Save.
        if inputObject == nil, expenseRepresented != nil {
            //we just save the edits. Simply pop the vc.
            self.navigationController?.popViewController(animated: true)
        } else {
            guard   let inputObject = inputObject,
                    inputObject.isComplete() else {
                    if expenseRepresented == nil {
                        let alert = UIAlertController(title: "Oops...", message: "Please fill in the necessary information.", preferredStyle: .alert)
                        alert.addAction(.init(title: "OK", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }
                    self.navigationController?.popViewController(animated: true)
                    return }
            if !isBeingEdited {
                //Create as many expenses as fit in the period.
                settings?.addRecurringExpense(expense: expenseRepresented!)
            } else {
                
            }
            
            //        print(settings)
            //        print(settings?.recurringExpenses)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let expense = expenseRepresented {
            navigationItem.title = expense.title
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CalendarCell {
            cell.calendarView.setDisplayDate(self.date!, animated: true)
            if let expense = expenseRepresented {
                cell.calendarView.selectDate(expense.datePurchased)
            }
        }
    }
}

extension RecurringExpenseViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let iPadHeight: CGFloat         = 600.0
        let maxHeight: CGFloat          = 290.0
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return (indexPath.row == 0) ? iPadHeight : 50
        } else {
            return (indexPath.row == 0) ? maxHeight : 50
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "calendarcell") as! CalendarCell
            let calendarView            = (cell as! CalendarCell).calendarView
            calendarView?.delegate      = self
            calendarView?.layer.maskedCorners   = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            calendarView?.clipsToBounds         = true
            setupCalendarView(calendarView: calendarView!)
            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "pricecell") as! RoundedTableViewCell
            (cell as! RoundedTableViewCell).layer.maskedCorners = []
            if let expense = expenseRepresented {
                let numberFormatter          = NumberFormatter()
                numberFormatter.numberStyle  = .currency
                numberFormatter.currencyCode = expense.currency.isoCode
                cell.detailTextLabel?.text   = numberFormatter.string(from: expense.price as NSNumber)
            }
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "notificationcell") as! SwitchTableViewCell
            (cell as! SwitchTableViewCell).layer.maskedCorners  = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            (cell as! SwitchTableViewCell).uiSwitch.isOn        = expenseRepresented?.notificationsOn ?? false
            cell.accessoryView                                  = nil
        default:
            cell = RoundedTableViewCell()
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 1, section: 0), expenseRepresented != nil {

            isBeingEdited       = true
            let storyboard      = UIStoryboard(name: "ExpenseInputViewController", bundle: nil)
            let inputVC         = storyboard.instantiateInitialViewController() as! ExpenseInputViewController
            inputVC.delegate    = self
            expense             = expenseRepresented
            self.date           = expenseRepresented?.datePurchased
            inputVC.currencyString = expenseRepresented?.currency.isoCode
            present(inputVC, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RecurringExpenseViewController: ExpenseInputDelegate {

    //MARK: Expense Input Delegate
    func pressedOKButton(_ view: InputView, ok button: AlertButton, input object: InputObject?) {
        
        if  let object = object,
            object.isComplete() {
            inputObject = object
            
            if let expRepr = expenseRepresented {
                expRepr.title = object.itemName
                expRepr.price = object.itemPrice
                expRepr.currency = object.currency
                expRepr.datePurchased = date!
                expRepr.updateDayOfMonth()
            } else {
                expenseRepresented = RecurringExpense(title: object.itemName,
                                                      price: object.itemPrice,
                                                      currency: object.currency.isoCode,
                                                      datePurchased: date!)
            }
            
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
            navigationItem.title = object.itemName
        }
        
    }
    
    func pressedCancelButton(_ view: InputView, cancel button: AlertButton, input object: InputObject?) {
        
    }
    
    //MARK: Calendar View Delegate
    func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {

    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {

        if expenseRepresented == nil {
            //show expense input view
            let storyboard      = UIStoryboard(name: "ExpenseInputViewController", bundle: nil)
            let inputVC         = storyboard.instantiateInitialViewController() as! ExpenseInputViewController
            inputVC.delegate    = self
            self.date           = date
            present(inputVC, animated: true, completion: nil)
            
        } else {
            let day = calendar.calendar.component(.day, from: date)
            if expenseRepresented!.dayOfMonth.day != day {
                let month = calendar.calendar.component(.month, from: date)
                label: if  month == 2,
                    expenseRepresented!.dayOfMonth.day! > day { //if it's february and the day is greater than 28, or 29 in leap years
                    break label
                
                } else {
                    expenseRepresented!.datePurchased = date
                    expenseRepresented!.updateDayOfMonth()
                }
            }
        }
       
    }

    func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool {
        return true
    }
    func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {
        
    }
    func calendar(_ calendar: CalendarView, didLongPressDate date: Date) {
        calendar.deselectDate(date)
    }
    
    func setupCalendarView(calendarView: CalendarView) {
        
        calendarView.direction                      = .horizontal
        calendarView.multipleSelectionEnable        = false
        calendarView.backgroundColor                = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        calendarView.layer.cornerRadius             = cornerRadius
        calendarView.layer.masksToBounds            = true
        CalendarView.Style.cellShape                = .round
        CalendarView.Style.cellColorDefault         = .clear
        CalendarView.Style.cellColorToday           = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        CalendarView.Style.headerTextColor          = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        CalendarView.Style.cellTextColorDefault     = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        CalendarView.Style.cellTextColorToday       = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        CalendarView.Style.cellTextColorWeekend     = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        CalendarView.Style.cellSelectedColor        = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        CalendarView.Style.cellSelectedTextColor    = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
}


