//
//  PanelViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 21/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import FAPanels

class PanelViewController: FAPanelController {

    override init() {
        super.init()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let leftMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "leftmenuvc") as! LeftMenuTableViewController
        let centerVC = mainStoryboard.instantiateViewController(withIdentifier: "centerNav") as! UINavigationController
        
        self.configs.leftPanelWidth = 200.0
        self.leftPanelPosition = .front
        self.configs.maxAnimDuration = 0.3
        
        self.configs.showDarkOverlayUnderLeftPanelOnTop = false
        
        _ = self.center(centerVC).left(leftMenuVC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let leftMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "leftmenuvc") as! LeftMenuTableViewController
        let centerVC = mainStoryboard.instantiateViewController(withIdentifier: "centerNav") as! UINavigationController
        
        self.configs.leftPanelWidth = 200
        self.leftPanelPosition = .front
        self.configs.maxAnimDuration = 0.3
        
        self.configs.showDarkOverlayUnderLeftPanelOnTop = false
        
        _ = self.center(centerVC).left(leftMenuVC)
        
    }
    
    override func openLeft(animated: Bool) {
        super.openLeft(animated: animated)
        
        self.left?.viewWillAppear(animated)
    }
}
