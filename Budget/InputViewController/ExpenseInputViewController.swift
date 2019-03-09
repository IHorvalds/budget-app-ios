//
//  ExpenseInputViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 09/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import NotificationCenter

protocol ExpenseInputDelegate {
    var date: Date? { get }
    var expense: Expense? { get set }
    func pressedOKButton(_ view: InputView, ok button: AlertButton, input object: InputObject?)
    func pressedCancelButton(_ view: InputView, cancel button: AlertButton, input object: InputObject?)
}


struct InputObject {
    let itemName: String
    let itemPrice: Double
    let currency: Currency
    
    func isComplete() -> Bool {
        if self.itemName.isEmpty || self.itemPrice == 0 || self.currency.isoCode.isEmpty {
            return false
        }
        return true
    }
}

@IBDesignable
class ExpenseInputViewController: UIViewController, CurrencyPickerViewDelegate {
    var turned: Int = 1
    
    
    var delegate: ExpenseInputDelegate?
    var currencyString: String?
    
    @IBOutlet weak var expenseInputView: InputView!
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        resignFirstResponder()
        
        let iObj = InputObject(itemName: itemNameTF.text ?? "", itemPrice: Double(itemPriceTF.text ?? "") ?? 0.0, currency: Currency(isoCode: currencyString ?? ""))
        
        //MARK: Call delegate function
        delegate?.pressedCancelButton(expenseInputView, cancel: cancelButton, input: iObj)
        
        
        let height = expenseInputView.frame.height + expenseInputView.frame.origin.y
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [unowned self] in
                        self.expenseInputView.transform = CGAffineTransform(translationX: 0, y: -height)
        }, completion: nil)
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func okButton(_ sender: AlertButton) {
        resignFirstResponder()
        
        let iObj = InputObject(itemName: itemNameTF.text ?? "", itemPrice: Double(itemPriceTF.text ?? "") ?? 0.0, currency: Currency(isoCode: currencyString ?? ""))
        
        let height = expenseInputView.frame.height + expenseInputView.frame.origin.y
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [unowned self] in
                        self.expenseInputView.transform = CGAffineTransform(translationX: 0, y: -height)
            }, completion: nil)
        dismiss(animated: true, completion: nil)
        delegate?.pressedOKButton(expenseInputView, ok: okButton, input: iObj)
    }
    @IBOutlet weak var cancelButton: AlertButton!
    @IBOutlet weak var okButton: AlertButton!
    @IBOutlet weak var currencyPicker: CurrencyPickerView!
    @IBOutlet weak var itemNameTF: UITextField!
    @IBOutlet weak var itemPriceTF: UITextField!
    var activeTF: UITextField?
    
    @objc func endEditingNow(_ sender: UITapGestureRecognizer) {
        activeTF?.resignFirstResponder()
    }
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButton(button: okButton, corners: [.layerMaxXMaxYCorner])
        setupButton(button: cancelButton, corners: [.layerMinXMaxYCorner])
        okButton.direction = -1.0
        
        
        //MARK: Currency picker delegate
        currencyPicker.currDelegate = self
        currencyPicker.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        currencyPicker.selectRow(currencyPicker.currencies.firstIndex(of: delegate?.expense?.currency.isoCode ?? "") ?? 0, inComponent: 0, animated: true)

        
        //MARK: itemNameTF become first responder
        itemNameTF.delegate     = self
        itemPriceTF.delegate    = self
        itemNameTF.becomeFirstResponder()
        itemNameTF.text         = delegate?.expense?.title
        
        //MARK: itemPriceTF may have a value when shown to change price
        itemPriceTF.text        = String(delegate?.expense?.price ?? 0.0)
        
        //MARK: Gesture recognizer
        self.view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(endEditingNow(_:)))
        
        //MARK: Showing the proper date
        let dateFormatter       = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        if let delegate = delegate {
            expenseInputView.dateLabel.text = dateFormatter.string(from: delegate.date ?? Date())
        } else {
            expenseInputView.dateLabel.text = dateFormatter.string(from: Date())
        }
        
        //MARK: Show proper modal transition
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle   = .crossDissolve
        
        //MARK: Notification about keyboard height
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardGoUp(notification:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardGoDown(notification:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)

    }
    

    
    func didSelectCurrency(_ currencyPicker: CurrencyPickerView, selected currency: String) {
        print(Currency(isoCode: currency).isoCode)
        self.currencyString = currency
    }
    
    func setupButton(button: UIButton, corners: CACornerMask) {
        button.layer.maskedCorners  = corners
        button.layer.cornerRadius   = cornerRadius
    }

}

extension ExpenseInputViewController: UITextFieldDelegate {
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTF = nil
    }

    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTF = textField
    }

    
    
}

extension ExpenseInputViewController {
    @objc func keyboardGoUp(notification: Notification) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardTop = keyboardRect.minY
                let aboveKeyboardTopFromViewBottom = abs((self.expenseInputView.frame.minY + self.expenseInputView.frame.height) - keyboardTop)
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: .curveEaseInOut,
                               animations: { [unowned self] in
                                self.expenseInputView.transform = CGAffineTransform(translationX: 0,
                                                                                    y: -aboveKeyboardTopFromViewBottom - 20.0)
                    }, completion: nil)
            }
        }
    }
    
    @objc func keyboardGoDown(notification: Notification) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: { [unowned self] in
                        self.expenseInputView.transform = CGAffineTransform.identity
            }, completion: nil)
    }
}
