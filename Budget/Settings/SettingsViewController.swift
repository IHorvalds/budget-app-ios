//
//  SettingsViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 05.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    //MARK: - Miscellaneous variables and constants
    let currencies = ["DKK", "EUR", "RON", "USD"]
    var activeTextField = UITextField()//used in identifying the text field being edited

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
        } else {
            if #available(iOS 10.0, *) {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.delegate = self
                if !checkNotificationAccess() {
                    activateNotifications(notificationCenter: notificationCenter)
                }
            } else {
                // Fallback on earlier versions
                // ????????
            }
        }
    }

    @IBOutlet weak var notificationSwitch: UISwitch!
    //MARK: - pop the settings view controller. Saving notifications explicitly because they are not useful for calculating the budget
    @IBAction func popSettingsVC(_ sender: Any) {
        saveToDefaults()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveToDefaults()
        defaults.set(notificationSwitch.isOn, forKey: notificationsAccessKey)
        if dateReceived.text != nil && dateReceived.text != "", lastsUntil.text != nil && lastsUntil.text != "", defaults.value(forKey: budgetForThisMonthKey) == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateFormatter.locale = Locale(identifier: "en_US")
            let calendar = Calendar.current
            let startingDate = dateFormatter.date(from: dateReceived.text!)!
            let startingComponents = calendar.dateComponents([.year, .month, .day], from: startingDate)
            let endingDate = dateFormatter.date(from: lastsUntil.text!)!
            let endingComponents = calendar.dateComponents([.year, .month, .day], from: endingDate)
            
            let start = calendar.date(from: startingComponents)
            let end = calendar.date(from: endingComponents)
            
            calculateDailyBudget(startingFrom: start! + TimeInterval(86400), endingOn: end! + TimeInterval(86400))
        }
    }
    
    //MARK: - pickerviews for currency and for dates
    let datePicker = UIDatePicker()
    let currPicker = UIPickerView()
    
    //MARK: - toolbar
    let toolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPressed(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
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
        sentCurrency.inputView = currPicker
        localCurrency.inputView = currPicker
        dateReceived.inputView = datePicker
        dateReceived.inputView = datePicker
        lastsUntil.inputView = datePicker
        rentDueDate.inputView = datePicker
        
        currPicker.delegate = self
        currPicker.dataSource = self
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(updateDateText), for: UIControlEvents.valueChanged)
        datePicker.backgroundColor = currPicker.backgroundColor
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let DateReceived = defaults.value(forKey: dateReceivedKey) as? String {
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
            if checkNotificationAccess() {
                notificationSwitch.isOn = NotificationAccess
                print(NotificationAccess)
            } else {
                notificationSwitch.isOn = false
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                dateReceived.becomeFirstResponder()
            case 1:
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("pressed return")
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
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if activeTextField == localCurrency {
            rentCurrency.text = currencies[row]
        }
        activeTextField.text = currencies[row]
    }
}

extension SettingsViewController {
    
    @objc func updateDateText() {
        let date = datePicker.date.description
        activeTextField.text = String(date.dropLast(15))
    }
}

extension SettingsViewController {
    
    func isItFilled() -> Bool {
        if (sentCurrency.text != "" &&
            localCurrency.text != "" &&
            lastsUntil.text != "" &&
            dateReceived.text != "" &&
            amountSent.text != "" &&
            rentDueDate.text != "" &&
            rentAmountInLocalCurrency.text != "") {
            return true
        } else {
            return false
        }
    }
    
    func saveToDefaults() {
        if !isItFilled() {       //first check to see that all fields have been filled
            let alert = UIAlertController(title: "Incomplete",
                                          message: "Please fill in all the information necessary for the budget.",
                                          preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in}
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        } else {                //save to defaults for each key
            defaults.set(dateReceived.text, forKey: dateReceivedKey)
            defaults.set(lastsUntil.text, forKey: lastsUntilKey)
            defaults.set(sentCurrency.text, forKey: sentCurrencyKey)
            defaults.set(localCurrency.text, forKey: localCurrencyKey)
            defaults.set(amountSent.text, forKey: budgetKey)
            defaults.set(rentAmountInLocalCurrency.text, forKey: rentAmountKey)
            defaults.set(rentDueDate.text, forKey: rentDueDateKey)
        }
    }
    
    @available(iOS 10.0, *)
    func activateNotifications(notificationCenter: UNUserNotificationCenter) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
            DispatchQueue.main.async {
                
                if let err = error {
                    print("there has been an error: \(err)")
                } else {
                    if !granted {
                        let alert = UIAlertController(title: "Please enable notifications",
                                                      message: "Notifications will make sure the app is running when the budget will be calculated and will remind you to pay the rent. Go to Settings to activate notifications",
                                                      preferredStyle: .alert)
                        alert.addAction(.init(title: "OK", style: .default, handler: { (action: UIAlertAction!) in}
                            ))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                self.notificationSwitch.isOn = granted
            }
        })
    }
    
    func checkNotificationAccess() -> Bool {
        let notificationTypes = UIApplication.shared.currentUserNotificationSettings?.types
        if notificationTypes == [] {
            print("notifications not enabled")
            return false
        } else {
            print("notifications enabled. But the user says they are: \(notificationSwitch.isOn)")
            return true
        }
    }
}
