//
//  InputView.swift
//  Budget
//
//  Created by Tudor Croitoru on 09/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class InputView: UIView {
    

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var usingCurrency: UILabel!
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        self.layer.cornerRadius     = cornerRadius
        header.layer.cornerRadius   = cornerRadius
        header.layer.masksToBounds  = true
        header.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let fontSize: CGFloat   = 15.0
        let buttonTextFont      = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        dateLabel.font          = buttonTextFont
        
        let effect                      = UIBlurEffect(style: .prominent)
        let effectView                  = UIVisualEffectView(effect: effect)
        effectView.frame                = self.frame
        effectView.frame.origin         = .zero
        effectView.layer.masksToBounds  = true
        effectView.layer.cornerRadius   = cornerRadius
        
        self.insertSubview(effectView, at: 0)
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
    }

}
