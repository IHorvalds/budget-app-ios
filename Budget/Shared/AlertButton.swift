//
//  AlertButton.swift
//  Budget
//
//  Created by Tudor Croitoru on 09/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class AlertButton: UIButton {

    let borderLayer = CALayer()
    let fontSize: CGFloat = 20.0
    lazy var buttonTextFont = UIFont.systemFont(ofSize: fontSize, weight: .light)
    var direction: CGFloat = 1.0
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        //MARK: Button Setup
        titleLabel?.font = buttonTextFont
        
        borderLayer.removeFromSuperlayer()
        
        borderLayer.frame = CGRect(origin: frame.origin,
                                   size: CGSize(width: direction * frame.width,
                                                height: 1.0))
        borderLayer.backgroundColor = UIColor.gray.cgColor
        layer.addSublayer(borderLayer)
    }

}
