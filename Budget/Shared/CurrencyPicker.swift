//
//  CurrencyPicker.swift
//  Budget
//
//  Created by Tudor Croitoru on 09/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

@objc protocol CurrencyPickerViewDelegate {
    var turned: Int { get set }
    @objc optional var fontSize: CGFloat { get set }
    func didSelectCurrency(_ currencyPicker: CurrencyPickerView, selected currency: String)
}

class CurrencyPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let currenciesCount = 32
    var currDelegate: CurrencyPickerViewDelegate?
    let currencies = Array(exchangeRates.keys).sorted()
    let font = UIFont.systemFont(ofSize: 5.0, weight: .light)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        dataSource = self
        showsSelectionIndicator = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
        showsSelectionIndicator = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exchangeRates.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currDelegate?.didSelectCurrency(self, selected: currencies[row])
    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        return NSAttributedString(string: currencies[row] + "🇹🇩", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
//                                                                        NSAttributedString.Key.font: font])
//    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 20.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 50.0, height: 20.0)))
        let font = UIFont.systemFont(ofSize: currDelegate?.fontSize ?? 15.0, weight: .medium)
        
        let label = UILabel(frame: view.frame)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints                     = false
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive        = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive      = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive    = true
        label.textColor = (self.isUserInteractionEnabled) ? #colorLiteral(red: 0.1041769013, green: 0.2801864147, blue: 0.4007718563, alpha: 1) : #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        label.font      = font
        
        label.text          = currencies[row]
        label.textAlignment = .center
        view.transform      = CGAffineTransform(rotationAngle: CGFloat(currDelegate?.turned ?? 1) * CGFloat.pi/2)
        
        return view
    }
}
