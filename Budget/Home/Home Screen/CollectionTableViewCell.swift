//
//  CollectionViewCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 26/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol CollectionDelegate {
    func showBudgetCollectionDelegate(budget: BudgetForDay?)
}

class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OverviewCollectionViewCellDelegate {
    func didTapBudgetDate(dateString: String) {
        //Show expenses view controller for the day that the cell represents
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: dateString)
        let budget = BudgetForDay.getBudgetForDate(date: date ?? Date())
        collectionDelegate?.showBudgetCollectionDelegate(budget: budget)
    }
    
    var moneyLeft: Double?
    var collectionDelegate: CollectionDelegate?

    
    var calendar        = Calendar(identifier: .gregorian)
    let today           = Date()
    let numberFormatter = NumberFormatter()
    let dateFormatter   = DateFormatter()
    var settings: Settings?
    
    let fontSize: CGFloat   = 18.0
    let cellTextFont        = UIFont.systemFont(ofSize: 18.0, weight: .light)
    
    
    var budgets: [BudgetForDay] = [BudgetForDay]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        var dateComponents  = DateComponents()
        
        numberFormatter.numberStyle = .currency
        dateFormatter.dateStyle     = .long
        
        collectionView.delegate     = self
        collectionView.dataSource   = self
        
        let _budgets = try? BudgetForDay.getBudgetsFromDefaults()
        
        for i in stride(from: 0, to: -7, by: -1) {
            dateComponents.day = i
            if let b = _budgets?.first(where: {Date.areSameDay(date1: $0.day, date2: calendar.date(byAdding: dateComponents, to: today)!)}) {
                budgets.append(b)
            }
        }
        budgets = budgets.reversed()
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.clipsToBounds    = false
        self.clipsToBounds              = false
    }
    
    
    //MARK: CollectionView stuff
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (budgets.count != 0) ? budgets.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var overviewcell = collectionView.dequeueReusableCell(withReuseIdentifier: "overviewcollectioncell", for: indexPath) as! OverViewCollectionViewCell
        
        overviewcell.delegate = self
        
        
        numberFormatter.currencyCode = settings?.incomeCurrency ?? NSLocale.current.currencyCode
        
        guard budgets.count > 0 else {
            overviewcell.dateButton.setTitle(dateFormatter.string(from: Date()), for: .normal)
            return overviewcell }
        
        let budget = budgets[indexPath.row]
            
        var expensesTotal: Double {
            var expenseTotal = 0.00
            for i in budget.expenses {
                expenseTotal += i.price
            }
            return expenseTotal
        }
        
        overviewcell.isInOrOverBudget.text  = isWithinBudget(date: budget.day)
        overviewcell.remainingToday.text    = "Remaining today: " + (numberFormatter.string(from: budget.totalUsableAmount as NSNumber) ?? "No data")
        overviewcell.spentToday.text        = "Spent today: " + (numberFormatter.string(from: expensesTotal as NSNumber) ?? "No data")
        overviewcell.checkBox.image         = (budget.totalUsableAmount >= 0) ? #imageLiteral(resourceName: "Rounded Checkbox") : #imageLiteral(resourceName: "Warning")
        
        overviewcell.remainingToday.font    = cellTextFont
        overviewcell.spentToday.font        = cellTextFont
        print(budget.day)
        overviewcell.dateButton.setTitle(dateFormatter.string(from: budget.day), for: .normal)
        
        return overviewcell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width - 2 * inset, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return inset/2
    }

    fileprivate func pagingScrollView(_ scrollView: UIScrollView) {
        let widthToMove = self.frame.width - inset * 3/2
        
        //round contentOffset.x to nearest i * widthToMove to imitate page enabling
        let x = round(scrollView.contentOffset.x / widthToMove) * widthToMove
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        pagingScrollView(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        pagingScrollView(scrollView)
    }
}
