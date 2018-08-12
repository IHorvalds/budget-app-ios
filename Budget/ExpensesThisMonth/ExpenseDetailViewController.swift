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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = purchaseTitle
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        datePurchased.text = dateFormatter.string(from: datePurchasedBuffer)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        if let localCurrency = defaults.value(forKey: localCurrencyKey) as? String {
            numberFormatter.currencyCode = localCurrency
        } else {
            numberFormatter.currencyCode = ""
        }
        price.text = numberFormatter.string(from: priceBuffer as NSNumber)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
