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
        //loadingIndicator.startAnimating()
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        let grow = CGAffineTransform(scaleX: 1.5, y: 1.5)
                        self.launchIcon.transform = grow
                        },
                       completion: nil)
        UIView.animate(withDuration: 1,
                       delay: 1,
                       options: [.curveEaseOut],
                       animations: {
                        let scale = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        self.launchIcon.alpha = 0.0
                        self.launchIcon.transform = scale
        }, completion: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
