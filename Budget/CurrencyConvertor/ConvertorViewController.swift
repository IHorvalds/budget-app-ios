//
//  ConvertorViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 11.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class ConvertorViewController: UITableViewController {
    var rowsInSectionOne = 1
    let currencies = Array(exchangeRates.keys)
    var baseCurrency = String()
    var amountToConvert: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.5803921569, green: 0.09019607843, blue: 0.3176470588, alpha: 1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ConvertorViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Select your currency and type in the amount"
        } else {
            return "Result"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return rowsInSectionOne
        } else {
            return currencies.count - 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 1 {
            return 150
        }
        
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0, indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyinputcell") as! BaseCurrencyCell?
            
            cell?.delegate = self
            
            return cell!
        } else if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencypickercell") as! CurrencyPickerCell?
            
            cell?.delegate = self
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencycell") as! ExchangeCurrencyCell?
            
            if baseCurrency != "" {
                let remainingCurrencies = currencies.filter({$0 != baseCurrency})
                
                let initialCurrency = Currency(isoCode: baseCurrency)
                let secondaryCurrency = Currency(isoCode: remainingCurrencies[indexPath.row])
                if  let exchangeAmount = amountToConvert,
                    let amountInCurrency = initialCurrency.convert(toCurrency: secondaryCurrency, amount: Double(exchangeAmount)!) {
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .currency
                    numberFormatter.currencyCode = " " //We already have the currency name on the left side of the cell
                    cell?.exchangeCurrencyAmount.text = numberFormatter.string(from: amountInCurrency as NSNumber)
                }
                
                cell?.exchangeCurrencyLabel?.text = remainingCurrencies[indexPath.row]
                
            }
            
            return cell!
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        if indexPath.section == 0, indexPath.row == 0 {
            
            tableView.beginUpdates()
            if rowsInSectionOne != 2 {
                rowsInSectionOne = 2
                tableView.insertRows(at: [IndexPath.init(row: 1, section: 0)], with: UITableView.RowAnimation.top)
                tableView.cellForRow(at: IndexPath.init(row: 1, section: 0))?.isHidden = false
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "OK", style: .done, target: self, action: #selector(removePicker))
            } else {
                removePicker()
            }
            tableView.endUpdates()
        }
    }
    
    @objc func removePicker() {
        rowsInSectionOne = 1
        tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .top)
        self.navigationItem.rightBarButtonItem = nil
        tableView.reloadSections([1], with: .none)
    }
}

extension ConvertorViewController: PickerTablewViewCellDelegate, BaseCurrencyCellDelegate {
    
    func didSelectRowFromPickerView(selected: String) {
        
        let baseCurrencyCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! BaseCurrencyCell?
        baseCurrencyCell?.baseCurrencyLabel.text = selected
        baseCurrency = selected
    }
    
    func didEnterAmount(amount: String?) {
        amountToConvert = amount
        if rowsInSectionOne == 2 {
            rowsInSectionOne = 1
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .top)
        }
        self.navigationItem.rightBarButtonItem = nil
        tableView.reloadData()
    }

}
