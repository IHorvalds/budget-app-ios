//
//  BudgetDocumentCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 19/03/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class BudgetDocumentCell: UICollectionViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius  = cornerRadius
        backgroundColor     = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 8.0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 8.5
        self.layer.masksToBounds = false
        self.clipsToBounds = false
    }
    
}
