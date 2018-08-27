//
//  BudgetExportViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 18.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit
import MobileCoreServices

class BudgetExportViewController: UITableViewController, UIDocumentPickerDelegate {
    
    var document: BudgetExportDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if document == nil {
            showDocumentPicker()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        document?.close(completionHandler: { (_) in
            print("Closed document")
        })
    }
    
    func showDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["horvalds.Budget.bdg"], in: .import)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        document = BudgetExportDocument(fileURL: urls.first!)
        document?.open(completionHandler: { [unowned self] (success) in
            
            let errorOpeningDocument = UIAlertController.init(title: "Error",
                                                              message: "There was an error opening your file. Try again.",
                                                              preferredStyle: .alert)
            
            if success {
                if self.document?.budgetExport != nil {
                    self.title = self.document?.localizedName
                    self.tableView.reloadData()
                    
                } else {
                    self.present(errorOpeningDocument,
                                 animated: true,
                                 completion: nil)
                }
            } else {
                
                self.present(errorOpeningDocument,
                        animated: true,
                        completion: nil)
                print("Error. Couldn't open document")
            }
            
            })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expensedetail" {
            if let destVC = segue.destination as? ExpenseDetailViewController {
                let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
                if let expenses = document?.budgetExport?.expenses {
                    destVC.purchaseTitle = expenses[(indexPath?.row)!].title
                    destVC.datePurchasedBuffer = expenses[(indexPath?.row)!].datePurchased
                    destVC.priceBuffer = expenses[(indexPath?.row)!].price
                    
                }
            }
        }
    }

}

extension BudgetExportViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if document?.documentState == .normal {
                return document?.budgetExport?.expenses?.count ?? 1
            }
            return 1 //once document is set, reload this to document.budgetExpenseData.expenses.count
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let dateCellTexts = ["Money received on", "Final day"]
        let moneyCellTexts = ["Total received", "Rent", "Total spent", "Total remaining"]
        
        //Formatting nicely
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        if let localCurrency = document?.budgetExport?.localCurrency {
            numberFormatter.currencyCode = localCurrency
        } else {
            numberFormatter.currencyCode = ""
        }
        dateFormatter.dateStyle = .medium
        
        //actually setting the cells
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "checkexpensecell")
            if document?.documentState == .normal,
                let expenses = document?.budgetExport?.expenses {
                    cell?.textLabel?.text = expenses[indexPath.row].title
                    cell?.detailTextLabel?.text = numberFormatter.string(from: expenses[indexPath.row].price as NSNumber)
            }
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "budgetdatecell")
            
            cell?.textLabel?.text = dateCellTexts[indexPath.row]
            if document?.documentState == .normal {
                if indexPath.row == 0 {
                    
                    let dateReceived = dateFormatter.date(from: (document?.budgetExport?.dateReceived)!)
                    let dateReceivedComponents = Calendar.current.dateComponents([.year, .month, .day], from: dateReceived!)
                    dateFormatter.dateStyle = .medium
                    cell?.detailTextLabel?.text = dateFormatter.string(from: Calendar.current.date(from: dateReceivedComponents)!)
                } else {
                    
                    let lastDay = dateFormatter.date(from: (document?.budgetExport?.lastDay)!)
                    let lastDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: lastDay!)
                    dateFormatter.dateStyle = .medium
                    cell?.detailTextLabel?.text = dateFormatter.string(from: Calendar.current.date(from: lastDayComponents)!)
                }
            }
            
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "budgetmoneycell")
            cell?.textLabel?.text = moneyCellTexts[indexPath.row]
            if document?.documentState == .normal {
                if indexPath.row == 0 {
                    cell?.detailTextLabel?.text = numberFormatter.string(from: (document?.budgetExport?.totalSent)! as NSNumber)
                } else if indexPath.row == 1 {
                    cell?.detailTextLabel?.text = numberFormatter.string(from: (document?.budgetExport?.rentAmount)! as NSNumber)
                } else {
                    cell?.detailTextLabel?.text = numberFormatter.string(from: (document?.budgetExport?.amountSpent)! as NSNumber)
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "budgetmoneycell")
            cell?.textLabel?.text = moneyCellTexts[3]
            if document?.documentState == .normal {
                cell?.detailTextLabel?.text = numberFormatter.string(from: (document?.budgetExport?.amountRemaining)! as NSNumber)
            }
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Expenses"
        }
        return nil
    }
}
