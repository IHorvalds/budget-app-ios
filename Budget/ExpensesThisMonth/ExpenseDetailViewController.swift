//
//  ExpenseDetailViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 12.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class ExpenseDetailViewController: UITableViewController {

    var purchaseTitle = String()
    var datePurchasedBuffer = Date()
    var priceBuffer = 0.0
    @IBOutlet weak var datePurchased: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var expenseTitle: UITextView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.indentationLevel = 0
        dateFormatter.dateStyle = .medium
        datePurchased.text = dateFormatter.string(from: datePurchasedBuffer)
        if purchaseTitle.count > 30 {
            self.navigationItem.title = dateFormatter.string(from: datePurchasedBuffer)
            expenseTitle.text = purchaseTitle
        } else {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.title = purchaseTitle
            tableView.cellForRow(at: IndexPath(row: 2, section: 0))?.isHidden = true
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        if let localCurrency = defaults.value(forKey: localCurrencyKey) as? String {
            numberFormatter.currencyCode = localCurrency
        } else {
            numberFormatter.currencyCode = ""
        }
        print(priceBuffer)
        price.text = numberFormatter.string(from: priceBuffer as NSNumber)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }

}
