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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return rowsInSectionOne
        } else {
            return exchangeRates.count - 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if indexPath.section == 0, indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "currencyinputcell")
        } else if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "currencypickercell")
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "currencycell")
        }
        
        return cell!
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row == 0 {
            tableView.beginUpdates()
            rowsInSectionOne = rowsInSectionOne + 1
            tableView.insertRows(at: [IndexPath.init(row: 1, section: 0)], with: UITableViewRowAnimation.top)
            tableView.cellForRow(at: IndexPath.init(row: 1, section: 0))?.isHidden = false
            tableView.endUpdates()
        }
    }
}

extension ConvertorViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exchangeRates.count
    }

}
