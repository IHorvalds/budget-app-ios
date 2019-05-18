//
//  Settings2ViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 10/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

@IBDesignable
class Settings2ViewController: UITableViewController {
    
    let numberFormatter     = NumberFormatter()
    let dateFormatter       = DateFormatter()
    var settings: Settings  = (try? Settings.getSettingsFromDefaults()) ?? Settings.standardSettings
    
    @IBAction func paymentIsRecurringSwitch(_ sender: UISwitch) {
        print("make payment recurrent: \(sender.isOn)")
        settings.recurringPayment = sender.isOn
    }
    
    @IBAction func leftMenuButton(_ sender: UIBarButtonItem) {
        panel?.openLeft(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settings.saveSettingsToDefaults()
        panel?.left?.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatter.numberStyle = .currency
        dateFormatter.dateStyle     = .medium
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        settings.saveSettingsToDefaults()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "addrecurringexpense",
            let destVC = segue.destination as? RecurringExpenseViewController {
            destVC.settings = settings
        }
        
        if  segue.identifier == "showrecurringexpense",
            let destVC = segue.destination as? RecurringExpenseViewController {
            destVC.settings = settings
            if let index = tableView.indexPathForSelectedRow {
                destVC.expenseRepresented = settings.recurringExpenses[index.row]
                destVC.expenseIndex       = index.row
            }
        }
        
        if  segue.identifier == "changeprofileinfosegue",
            let destVC = segue.destination as? ProfileTableViewController {
            destVC.settings = settings
        }
        
        if  segue.identifier == "editsettingsegue",
            let destVC = segue.destination as? FieldEditingTableViewController {
            destVC.settings = settings
            destVC.navigationItem.title = (sender as? UITableViewCell)?.textLabel?.text
            if let index = tableView.indexPathForSelectedRow {
                switch index.row {
                case 0:
                    destVC.attributeToEdit = [.IncomeAmount, .IncomeCurrency]
                    destVC.selectedCurrency = settings.incomeCurrency
                case 1:
                    destVC.attributeToEdit = [.PaymentDate, .MustLastUntil]
                case 3:
                    destVC.attributeToEdit = [.PaymentDate, .MustLastUntil]
                case 4:
                    destVC.attributeToEdit = [.SavingsTarget]
                default:
                    break
                }
            }
        }
    }

}

extension Settings2ViewController: UIPopoverPresentationControllerDelegate {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (settings.recurringExpenses.isEmpty) ? 2 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 5
        default:
            return settings.recurringExpenses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        switch indexPath.section {
            
        case 0:
            cell                                                = tableView.dequeueReusableCell(withIdentifier: "userpicturecell") as! ProfileTableViewCell
            (cell as! ProfileTableViewCell).userName.text       = settings.userName
            (cell as! ProfileTableViewCell).userPicture.image   = Settings.decodeImageFromBase64(strBase64: settings.userImage)
            
            
        case 1:
            switch indexPath.row {
            case 0:
                cell                            = tableView.dequeueReusableCell(withIdentifier: "incomecell") as! RoundedTableViewCell
                cell?.textLabel?.text           = "Income"
                numberFormatter.currencyCode    = settings.incomeCurrency
                let detailText                  = (settings.incomeAmount > 0.0) ? numberFormatter.string(from: settings.incomeAmount as NSNumber)! : "No data"
                cell?.detailTextLabel?.text     = detailText
                (cell as! RoundedTableViewCell).layer.maskedCorners       = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                (cell as! RoundedTableViewCell).clipsToBounds       = false
                
                
            case 1:
                cell                            = tableView.dequeueReusableCell(withIdentifier: "startdatecell") as! RoundedTableViewCell
                cell?.textLabel?.text           = "Payment date"
                let detailText                  = (settings.paymentDate != nil) ? dateFormatter.string(from: (settings.paymentDate)!) : "No data"
                cell?.detailTextLabel?.text     = detailText
                (cell as! RoundedTableViewCell).layer.maskedCorners       = []
                (cell as! RoundedTableViewCell).clipsToBounds       = false
                
                
            case 2:
                cell                            = tableView.dequeueReusableCell(withIdentifier: "recurringcell") as! SwitchTableViewCell
                (cell as! SwitchTableViewCell).uiSwitch.isOn = settings.recurringPayment
                (cell as! SwitchTableViewCell).layer.maskedCorners = []
                (cell as! SwitchTableViewCell).layer.masksToBounds = false
                
                (cell as! SwitchTableViewCell).detailInfoButton.addTarget(self, action: #selector(showRecurringPaymentInfo), for: UIControl.Event.allTouchEvents)
                
                
            case 3:
                cell                            = tableView.dequeueReusableCell(withIdentifier: "enddatecell") as! RoundedTableViewCell
                cell?.textLabel?.text           = "Must last until"
                let detailText                  = (settings.mustLastUntil != nil) ? dateFormatter.string(from: (settings.mustLastUntil)!) : "No data"
                cell?.detailTextLabel?.text     = detailText
                (cell as! RoundedTableViewCell).layer.maskedCorners = []
                (cell as! RoundedTableViewCell).clipsToBounds = false
                
            default:
                cell                            = tableView.dequeueReusableCell(withIdentifier: "savingstargetcell") as! RoundedTableViewCell
                cell?.textLabel?.text           = "Savings target"
                let target                      = settings.savingsTarget
                numberFormatter.currencyCode    = settings.incomeCurrency
                cell?.detailTextLabel?.text     = (target > 0.0) ? numberFormatter.string(from: target as NSNumber) : "None"
                (cell as! RoundedTableViewCell).layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                (cell as! RoundedTableViewCell).clipsToBounds = false
            }
            
            
        default:
            cell                    = tableView.dequeueReusableCell(withIdentifier: "recurringexpensecell") as! ExpenseCell
            cell?.textLabel?.text   = settings.recurringExpenses[indexPath.row].title
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0, indexPath.section == 0 {
            return 280.0 //according to design fucker
        } else {
            return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Profile"
        case 1:
            return nil
        default:
            return "Scheduled expenses"
        }
    }
    
    @objc func showRecurringPaymentInfo() {
        let storyboard = UIStoryboard(name: "Settings2", bundle: nil)
        let popoverVC = storyboard.instantiateViewController(withIdentifier: "popoverinfo")
        popoverVC.modalPresentationStyle = .popover
        
        if  let popover = popoverVC.popoverPresentationController {
            let detailButton = (tableView.cellForRow(at: IndexPath(item: 2, section: 1)) as! SwitchTableViewCell).detailInfoButton
            popover.sourceView = detailButton
            popover.sourceRect = detailButton.bounds.insetBy(dx: detailButton.bounds.width/2, dy: 0)
            popover.delegate = self
            popover.permittedArrowDirections = [.down]
            popover.backgroundColor = .groupTableViewBackground
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            print("segue to change personal data")
        case 1:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "editsettingsegue", sender: tableView.cellForRow(at: indexPath))
            case 1:
                performSegue(withIdentifier: "editsettingsegue", sender: tableView.cellForRow(at: indexPath))
            case 2:
                return
            case 3:
                performSegue(withIdentifier: "editsettingsegue", sender: tableView.cellForRow(at: indexPath))
            default:
                performSegue(withIdentifier: "editsettingsegue", sender: tableView.cellForRow(at: indexPath))
            }
        default:
            print("segue to recurring expense input view controller with data from settings")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if editingStyle == .delete {
                settings.removeRecurringExpense(at: indexPath.row)
                if settings.recurringExpenses.count == 0 {
                    tableView.deleteSections(IndexSet(integer: 2), with: .fade)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
