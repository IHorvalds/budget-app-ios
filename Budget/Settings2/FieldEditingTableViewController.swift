//
//  FieldEditingTableViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 23/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class FieldEditingTableViewController: UITableViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    var activeTF = UITextField()
    var turned: Int = 0
    var fontSize: CGFloat = 30.0
    var settings: Settings?
    var attributeToEdit: [Settings.Attribute]?
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let currPicker = CurrencyPickerView()
    var selectedCurrency: String?
    let numberFormatter = NumberFormatter()
    var initialSavingsText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle     = .long
        numberFormatter.numberStyle = .currency
        initialSavingsText          = String(settings?.savingsTarget ?? 0.0)
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backItem?.backBarButtonItem?.title = " "
        textField.attributedPlaceholder = NSAttributedString(string: (navigationItem.title ?? "") + "...",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        currPicker.currDelegate = self
        
        textField.delegate  = self
        secondTF.delegate   = self
        
        textField.enablesReturnKeyAutomatically = true
        secondTF.enablesReturnKeyAutomatically  = true
        
        if attributeToEdit == [.IncomeAmount, .IncomeCurrency] {
            secondTF.attributedPlaceholder = NSAttributedString(string: "Currency...",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
            
            textField.keyboardType = .decimalPad
            secondTF.inputView = currPicker
            
            if let settings = settings {
                textField.text  = String(settings.incomeAmount)
                secondTF.text   = settings.incomeCurrency
            }
        }
        
        if attributeToEdit == [.PaymentDate, .MustLastUntil] {
            secondTF.attributedPlaceholder = NSAttributedString(string: "Must last until...",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
            
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(updateDateText), for: UIControl.Event.valueChanged)
            textField.inputView     = datePicker
            secondTF.inputView      = datePicker
            textField.textAlignment = .right
            secondTF.textAlignment  = .right
            
            if let settings = settings {
                textField.text  = dateFormatter.string(from: settings.paymentDate ?? Date())
                secondTF.text   = dateFormatter.string(from: settings.mustLastUntil ?? Date())
            }
        }
        
        if attributeToEdit == [.SavingsTarget] {
            textField.keyboardType = .decimalPad
            textField.clearsOnInsertion = true
            if let settings = settings {
                numberFormatter.currencyCode = settings.incomeCurrency
                textField.text = numberFormatter.string(from: settings.savingsTarget as NSNumber)
            }
        }
        
        if attributeToEdit == [.UserName] {
            textField.clearsOnInsertion = true
            textField.textContentType = .givenName
            if let settings = settings {
                textField.text = settings.userName
            }
        }
        
        if attributeToEdit == [.PreferredCurrency] {
            selectedCurrency = settings?.preferredCurrency
            textField.clearsOnInsertion = true
            textField.inputView         = currPicker
            if let settings = settings {
                textField.text = settings.preferredCurrency
            }
        }
        
    
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.isHidden = true
        tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.clipsToBounds = true
        
        if attributeToEdit == [.IncomeAmount, .IncomeCurrency] || attributeToEdit == [.PaymentDate, .MustLastUntil] {
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.isHidden = false
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.clipsToBounds = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let text = textField.text {
            if let currency = selectedCurrency {
                if attributeToEdit == [.IncomeAmount, .IncomeCurrency] {
                    settings?.saveSettingField(string: currency, field: .IncomeCurrency)
                    settings?.saveSettingField(double: Double(text) ?? 0.0, field: .IncomeAmount)
                }
            }
            
            if attributeToEdit == [.UserName] {
                settings?.saveSettingField(string: text, field: .UserName)
            }
            
            if attributeToEdit == [.PreferredCurrency] {
                settings?.saveSettingField(string: selectedCurrency ?? NSLocale.current.currencyCode!, field: .PreferredCurrency)
            }
            
            if attributeToEdit == [.SavingsTarget] {
                settings?.saveSettingField(double: Double(initialSavingsText) ?? 0.0, field: .SavingsTarget)
            }
            
            if attributeToEdit == [.PaymentDate, .MustLastUntil] {
                if  let startDate = dateFormatter.date(from: text),
                    let endDate   = dateFormatter.date(from: secondTF.text ?? "") {
                    
                    settings?.saveSettingField(date: startDate, field: .PaymentDate)
                    settings?.saveSettingField(date: endDate, field: .MustLastUntil)
                }
            }
        }
    }
    
    @objc func updateDateText() {
        let date = datePicker.date
        activeTF.text = dateFormatter.string(from: date)
    }

}

extension NSLocale {
    
    static func currencySymbolFromCode(code: String) -> String? {
        let localeIdentifier = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.currencyCode.rawValue : code])
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        return locale.object(forKey: NSLocale.Key.currencySymbol) as? String
    }
    
}

extension FieldEditingTableViewController: UITextFieldDelegate, CurrencyPickerViewDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTF = textField
        if  textField == secondTF,
            let date = dateFormatter.date(from: self.textField.text ?? "") {
            datePicker.minimumDate = date
        } else {
            if textField == textField {
                datePicker.minimumDate = Calendar.autoupdatingCurrent.date(byAdding: .month, value: -1, to: Date())
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if attributeToEdit == [.SavingsTarget] {
            initialSavingsText = textField.text ?? ""
            textField.text = numberFormatter.string(from: (Double(initialSavingsText) ?? 0.0) as NSNumber)
            settings?.saveSettingField(double: Double(initialSavingsText) ?? 0.0, field: .SavingsTarget)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func didSelectCurrency(_ currencyPicker: CurrencyPickerView, selected currency: String) {
        selectedCurrency = currency
        activeTF.text = NSLocale.currencySymbolFromCode(code: currency) ?? currency
    }
    
}
