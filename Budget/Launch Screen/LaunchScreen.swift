//
//  LaunchScreen.swift
//  Budget
//
//  Created by Tudor Croitoru on 23/08/2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController {
    

    
    
    @IBOutlet weak var launchIcon: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        let grow = CGAffineTransform(scaleX: 1.5, y: 1.5)
                        self.launchIcon.transform = grow
        },
                       completion: { success in
                        UIView.animate(withDuration: 0.5,
                                       delay: 0,
                                       options: [.curveEaseOut],
                                       animations: {
                                        let scale = CGAffineTransform(scaleX: 0.2, y: 0.2)
                                        self.launchIcon.alpha = 0.0
                                        self.launchIcon.transform = scale
                        }, completion: nil)})
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
