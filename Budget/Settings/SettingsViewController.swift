//
//  SettingsViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 05.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit
import UserNotifications

let dateFormatter = DateFormatter()

class SettingsViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    //MARK: - Miscellaneous variables and constants
    //let currencies = ["DKK", "EUR", "RON", "USD"]
    let currencies = Array(exchangeRates.keys)
    var activeTextField = UITextField()//used in identifying the text field being edited
    let notificationCenter = UNUserNotificationCenter.current()

    //MARK: - variables

    @IBOutlet weak var localCurrency: UITextField!
    @IBOutlet weak var sentCurrency: UITextField!
    @IBOutlet weak var lastsUntil: UITextField!
    @IBOutlet weak var dateReceived: UITextField!
    @IBOutlet weak var amountSent: UITextField!
    @IBOutlet weak var rentDueDate: UITextField!
    @IBOutlet weak var rentAmountInLocalCurrency: UITextField!
    @IBOutlet weak var rentCurrency: UILabel!
    @IBAction func notificationAccessSwitch(_ sender: UISwitch) {
        if !sender.isOn {
            //don't send shit
            print("notifications disabled")
            notificationCenter.removeAllPendingNotificationRequests()
        } else {
            checkNotificationAccess()
        }
    }

    @IBOutlet weak var notificationSwitch: UISwitch!
    //MARK: - pop the settings view controller. Saving notifications explicitly because they are not useful for calculating the budget
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        saveToDefaults()
        defaults.set(notificationSwitch.isOn, forKey: notificationsAccessKey)
        if dateReceived.text != nil && dateReceived.text != "", lastsUntil.text != nil && lastsUntil.text != "", defaults.value(forKey: budgetForThisMonthKey) == nil {
            dateFormatter.dateStyle = .medium
            let calendar = Calendar.current
            let startingDate = dateFormatter.date(from: dateReceived.text!)!
            let startingComponents = calendar.dateComponents([.year, .month, .day], from: startingDate)
            let endingDate = dateFormatter.date(from: lastsUntil.text!)!
            let endingComponents = calendar.dateComponents([.year, .month, .day], from: endingDate)
            
            let start = calendar.date(from: startingComponents)
            let end = calendar.date(from: endingComponents)
            calculateDailyBudget(startingFrom: start!, endingOn: end!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Settings view will disappear")
        saveToDefaults()
        defaults.set(notificationSwitch.isOn, forKey: notificationsAccessKey)
        if dateReceived.text != nil && dateReceived.text != "", lastsUntil.text != nil && lastsUntil.text != "", defaults.value(forKey: budgetForThisMonthKey) == nil {
            dateFormatter.dateStyle = .medium
            let calendar = Calendar.current
            let startingDate = dateFormatter.date(from: dateReceived.text!)!
            let startingComponents = calendar.dateComponents([.year, .month, .day], from: startingDate)
            let endingDate = dateFormatter.date(from: lastsUntil.text!)!
            let endingComponents = calendar.dateComponents([.year, .month, .day], from: endingDate)
            
            let start = calendar.date(from: startingComponents)
            let end = calendar.date(from: endingComponents)
            calculateDailyBudget(startingFrom: start!, endingOn: end!)
        }
    }
    
    //MARK: - pickerviews for currency and for dates
    let datePicker = UIDatePicker()
    let currPicker = UIPickerView()
    let rentPicker = UIPickerView()
    
    //MARK: - toolbar
    let toolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.delegate = self
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPressed(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        
        self.addToolbar(textField: amountSent)
        self.addToolbar(textField: rentAmountInLocalCurrency)
        self.addToolbar(textField: dateReceived)
        self.addToolbar(textField: lastsUntil)
        self.addToolbar(textField: rentDueDate)
        self.addToolbar(textField: sentCurrency)
        self.addToolbar(textField: localCurrency)
        
        datePicker.locale = Calendar.current.locale
        sentCurrency.inputView = currPicker
        localCurrency.inputView = currPicker
        dateReceived.inputView = datePicker
        lastsUntil.inputView = datePicker
        rentDueDate.inputView = rentPicker
        
        currPicker.delegate = self
        currPicker.dataSource = self
        rentPicker.delegate = self
        rentPicker.dataSource = self
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(updateDateText), for: UIControl.Event.valueChanged)
        datePicker.backgroundColor = currPicker.backgroundColor
        
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
            }
        })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let DateReceived = defaults.value(forKey: dateReceivedKey) as? String {
            print("They still exist")
            dateReceived.text = DateReceived
        }
        if let LastsUntil = defaults.value(forKey: lastsUntilKey) as? String {
            lastsUntil.text = LastsUntil
        }
        if let RentDueDate = defaults.value(forKey: rentDueDateKey) as? String {
            rentDueDate.text = RentDueDate
        }
        if let SentCurrency = defaults.value(forKey: sentCurrencyKey) as? String {
            sentCurrency.text = SentCurrency
        }
        if let LocalCurrency = defaults.value(forKey: localCurrencyKey) as? String {
            localCurrency.text = LocalCurrency
            rentCurrency.text = LocalCurrency
        }
        if let AmountSent = defaults.value(forKey: budgetKey) as? String {
            amountSent.text = AmountSent
        }
        if let RentAmount = defaults.value(forKey: rentAmountKey) as? String {
            rentAmountInLocalCurrency.text = RentAmount
        }
        if let NotificationAccess = defaults.value(forKey: notificationsAccessKey) as? Bool {
            notificationCenter.getNotificationSettings { [weak self] (settings) in
                
                if settings.authorizationStatus == .authorized {
                    self?.notificationSwitch.isOn = NotificationAccess
                } else {
                    self?.notificationSwitch.isOn = false
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                dateReceived.becomeFirstResponder()
            case 1:
                print(dateReceived.hasText)
                if dateReceived.hasText {
                    dateFormatter.dateStyle = .medium
                    let calendar = Calendar.current
                    let startingDate = dateFormatter.date(from: dateReceived.text!)!
                    let startingComponents = calendar.dateComponents([.year, .month, .day], from: startingDate)
                    datePicker.minimumDate = calendar.date(from: startingComponents)
                }
                lastsUntil.becomeFirstResponder()
            case 2:
                sentCurrency.becomeFirstResponder()
            case 3:
                amountSent.becomeFirstResponder()
            default:
                localCurrency.becomeFirstResponder()
            }
        } else {
            switch indexPath.row {
            case 0:
                rentAmountInLocalCurrency.becomeFirstResponder()
            case 1:
                rentDueDate.becomeFirstResponder()
            default:
                print("notifications access. Not working")
            }
       }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            var initialCurr: Currency
            var localCurr: Currency
            if let curr = sentCurrency.text, let curr2 = localCurrency.text, let totalAmount = amountSent.text {
                initialCurr = Currency.init(isoCode: curr)
                localCurr = Currency.init(isoCode: curr2)
                if let totAmount = Double(totalAmount), let quantity = initialCurr.convert(toCurrency: localCurr, amount: totAmount) {
                    return "Amount in local currency: " + String(quantity)
                }
            }
            return "Amount in local currency: ???"
        } else {
            if let curr = sentCurrency.text, let curr2 = localCurrency.text, let totalAmount = amountSent.text, let rentAmount = rentAmountInLocalCurrency.text {
                let initialCurr = Currency.init(isoCode: curr)
                let localCurr = Currency.init(isoCode: curr2)
                if let rentAm = Double(rentAmount), let totAmount = Double(totalAmount), let quantity = initialCurr.convert(toCurrency: localCurr, amount: totAmount) {
                    let quantityAfterRent = quantity - rentAm
                    return "Amount after rent: " + String(quantityAfterRent) + curr2
                } else {
                    return "Amount after rent: ???"
                }
            } else {
                return "Amount after rent: ???"
            }
        }
    }

}

extension SettingsViewController: UITextFieldDelegate {

    func addToolbar (textField: UITextField) {
        textField.inputAccessoryView = toolbar
    }
    
    @objc func donePressed(){
        view.endEditing(true)
        self.tableView.reloadData()
    }
    
    @objc func cancelPressed(sender: UIButton){
        
        activeTextField.text = ""
        self.tableView.reloadData()
        view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == lastsUntil {
            if dateReceived.text != "" {
                dateFormatter.dateStyle = .medium
                let calendar = Calendar.current
                let startingDate = dateFormatter.date(from: dateReceived.text!)
                let startingComponents = calendar.dateComponents([.year, .month, .day], from: startingDate!)
                datePicker.minimumDate = calendar.date(from: startingComponents)
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tableView.reloadData()
        return true
    }
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == currPicker {
            return currencies.count
        } else {
            return 28
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == currPicker {
            return currencies[row]
        } else {
            if (row + 1) % 10 == 1, (row + 1) != 11 {
                return String(row + 1) + "st"
            } else if (row + 1) % 10 == 2, (row + 1) != 12 {
                return String(row + 1) + "nd"
            } else if (row + 1) % 10 == 3, (row + 1) != 13 {
                return String(row + 1) + "rd"
            }
            
            return String(row + 1) + "th"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == currPicker {
            if activeTextField == localCurrency {
                rentCurrency.text = currencies[row]
            }
            activeTextField.text = currencies[row]
        } else {
            activeTextField.text = "Day " + String(row + 1)
        }
    }
}

extension SettingsViewController {
    
    @objc func updateDateText() {
        dateFormatter.dateStyle = .medium
        let date = datePicker.date
        activeTextField.text = dateFormatter.string(from: date)
    }
}

extension SettingsViewController {
    
    func isItFilled() -> Bool {
        if (sentCurrency.text != "" &&
            localCurrency.text != "" &&
            lastsUntil.text != "" &&
            dateReceived.text != "" &&
            amountSent.text != "" &&
            rentAmountInLocalCurrency.text != "") {
            print("It's been filled")
            return true
        } else {
            print("It hasn't been filled")
            return false
        }
    }
    
    func saveToDefaults() {
        if !isItFilled() {       //first check to see that all fields have been filled
            if let rentDate = rentDueDate.text {
                defaults.set(rentDate, forKey: rentDueDateKey)
            }
            
            let alert = UIAlertController(title: "Incomplete",
                                          message: "Please fill in all the information necessary for the budget.",
                                          preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in}
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else {                //save to defaults for each key
            
            //if values do exist for the keys in UserDefaults and are different than what is now on screen, then calculateBudget again
            if  let a = defaults.value(forKey: dateReceivedKey) as? String,
                let b = defaults.value(forKey: lastsUntilKey) as? String,
                let c = defaults.value(forKey: sentCurrencyKey) as? String,
                let d = defaults.value(forKey: localCurrencyKey) as? String,
                let e = defaults.value(forKey: budgetKey) as? String,
                let f = defaults.value(forKey: rentAmountKey) as? String {
                if a != dateReceived.text
                || b != lastsUntil.text
                || c != sentCurrency.text
                || d != localCurrency.text
                || e != amountSent.text
                || f != rentAmountInLocalCurrency.text {
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.dateStyle = .medium
                    let calendar = Calendar.current
                    let startingDate = dateFormatter.date(from: dateReceived.text!)!
                    let startingComponents = calendar.dateComponents([.year, .month, .day], from: startingDate)
                    let endingDate = dateFormatter.date(from: lastsUntil.text!)!
                    let endingComponents = calendar.dateComponents([.year, .month, .day], from: endingDate)
                    
                    let start = calendar.date(from: startingComponents)
                    let end = calendar.date(from: endingComponents)
                    defaults.set(dateReceived.text, forKey: dateReceivedKey)
                    defaults.set(lastsUntil.text, forKey: lastsUntilKey)
                    defaults.set(sentCurrency.text, forKey: sentCurrencyKey)
                    defaults.set(localCurrency.text, forKey: localCurrencyKey)
                    defaults.set(amountSent.text, forKey: budgetKey)
                    defaults.set(rentAmountInLocalCurrency.text, forKey: rentAmountKey)
                    calculateDailyBudget(startingFrom: start!, endingOn: end!)
                    
                    //update every day's budget with the expenses of that day
                    var budgets = NSKeyedUnarchiver.unarchiveObject(with: (defaults.value(forKey: budgetForThisMonthKey) as! Data)) as! [BudgetForDay]
                    print(budgets)
                    if  let expenseData = defaults.value(forKey: expensesKey) as? Data,
                        let expenses = NSKeyedUnarchiver.unarchiveObject(with: expenseData) as? [Expense] {
                        for budget in budgets {
                            print("Budget date: \(budget.day)")
                            let matchingExpenses = expenses.filter({$0.datePurchased == budget.day})
                            for expense in matchingExpenses {
                                print("updating expense")
                                budget.updateTotalUsableAmount(expense: expense)
                            }
                            
                            budgets[(budgets.index(of: budget))!] = budget
                        }
                        defaults.set(archiveBudgetsAsData(budgets: budgets), forKey: budgetForThisMonthKey)
                    }
                }
            } else {
                print("saving shit to UserDefaults after it being empty")
                defaults.set(dateReceived.text, forKey: dateReceivedKey)
                defaults.set(lastsUntil.text, forKey: lastsUntilKey)
                defaults.set(sentCurrency.text, forKey: sentCurrencyKey)
                defaults.set(localCurrency.text, forKey: localCurrencyKey)
                defaults.set(amountSent.text, forKey: budgetKey)
                defaults.set(rentAmountInLocalCurrency.text, forKey: rentAmountKey)
            }
            
            
            defaults.set(rentDueDate.text, forKey: rentDueDateKey)
        }
    }
    
    func setDailyBudgetNotification() {
        //set notification reminder for daily budget updates
        let content = UNMutableNotificationContent()
        content.title = "Add your spendings for the day"
        content.body = "It's 22:22 and somebody loves you. Now gather your receipts and see how much you spent today!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 22
        let date = Calendar.autoupdatingCurrent.date(from: dateComponents)
        let dateComponents2 = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents2, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    func setMonthlyRentNotification(day rentDay: String) {
        //set notification for rent due date
        let content = UNMutableNotificationContent()
        content.title = "Rent due today"
        content.body = "If you haven't already, pay your rent sometime today!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.day = Int(rentDay.dropFirst(4))
        dateComponents.hour = 12
        let date = Calendar.autoupdatingCurrent.date(from: dateComponents)
        let dateComponents2 = Calendar.autoupdatingCurrent.dateComponents([.day, .hour], from: date!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents2, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    func checkNotificationAccess() {
        notificationCenter.getNotificationSettings { [weak self] (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                print("Notifications allowed and desired by the user")
                self?.setDailyBudgetNotification()
                if let rentDay = defaults.value(forKey: rentDueDateKey) as? String {
                    self?.setMonthlyRentNotification(day: rentDay)
                }
                self?.notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
                    for request in requests {
                        print(request)
                    }
                })
            case .denied:
                print("Notifications disallowed and desired by the user")
                let alert = UIAlertController.init(title: "Please enable notifications",
                                                   message: "Notifications will make sure the app is running when the budget will be calculated and will remind you to pay the rent. Go to Settings to activate notifications.",
                                                   preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: { (_: UIAlertAction!) in
                    self?.notificationSwitch.isOn = false
                }
                    ))
                
                self?.present(alert, animated: true, completion: nil)
            case .notDetermined:
                print("User wished notifications. Asking for permission")
                self?.notificationCenter.requestAuthorization(options: [.badge, .sound, .alert],
                                                              completionHandler: { (allowed, error) in
                                                                DispatchQueue.main.async {
                                                                    
                                                                    if let err = error {
                                                                        print("there has been an error: \(err)")
                                                                    } else {
                                                                        if !allowed {
                                                                            let alert = UIAlertController(title: "Please enable notifications",
                                                                                                          message: "Notifications will make sure the app is running when the budget will be calculated and will remind you to pay the rent. Go to Settings to activate notifications",
                                                                                                          preferredStyle: .alert)
                                                                            alert.addAction(.init(title: "OK", style: .default, handler: { (_: UIAlertAction!) in}
                                                                                ))
                                                                            self?.present(alert, animated: true, completion: nil)
                                                                        } else {
                                                                            UIApplication.shared.registerForRemoteNotifications()
                                                                            
                                                                        }
                                                                    }
                                                                    self?.notificationSwitch.isOn = allowed
                                                                }
                                                                
                })
            case .provisional:
                print("What is this???")
            }
        }
    }
}
