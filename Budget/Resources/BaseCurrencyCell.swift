//
//  BaseCurrencyCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 27/08/2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol BaseCurrencyCellDelegate {
    func didEnterAmount(amount: String?)
}

class BaseCurrencyCell: RoundedTableViewCell {

    @IBOutlet weak var baseCurrencyLabel: UILabel!
    @IBOutlet weak var exchangeAmountTextField: UITextField!
    let toolbar = UIToolbar()
    var delegate: BaseCurrencyCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPressed(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        
        self.addToolbar(textField: exchangeAmountTextField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension BaseCurrencyCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        delegate?.didEnterAmount(amount: exchangeAmountTextField.text)
        return true
    }
    
    func addToolbar (textField: UITextField) {
        textField.inputAccessoryView = toolbar
    }
    
    @objc func donePressed(){
        self.endEditing(true)
        print(self.exchangeAmountTextField.hasText)
        delegate?.didEnterAmount(amount: exchangeAmountTextField.text)
    }
    
    @objc func cancelPressed(sender: UIButton){
        
        exchangeAmountTextField.text = ""
        self.endEditing(true)
    }
}
