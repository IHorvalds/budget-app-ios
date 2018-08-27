//
//  CurrencyPickerCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 26/08/2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol PickerTablewViewCellDelegate {
    func didSelectRowFromPickerView(selected: String)
}

class CurrencyPickerCell: RoundedTableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    let currencyPicker = UIPickerView()
    let currencies = Array(exchangeRates.keys)
    var delegate: PickerTablewViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        self.addSubview(currencyPicker)
        currencyPicker.translatesAutoresizingMaskIntoConstraints = false
        currencyPicker.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        currencyPicker.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        currencyPicker.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        currencyPicker.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
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
        delegate?.didSelectRowFromPickerView(selected: currencies[row])
    }
}
