//
//  LeftMenuTableViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 21/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class LeftMenuTableViewController: UITableViewController {
    
    let headerView  = UIView(frame: CGRect.zero)
    let label       = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 20)))
    let imageView   = UIImageView(image: #imageLiteral(resourceName: "jason-leung-733274-unsplash"))
    let titleLabel  = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 20)))

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let settings    = try? Settings.getSettingsFromDefaults()
        imageView.image = Settings.decodeImageFromBase64(strBase64: settings?.userImage ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //        TODO: Fork FAPanels and add these options for .front as well
//        panel!.configs.centerPanelTransitionType = .moveRight
//        panel!.configs.centerPanelTransitionDuration = 0.3
//        panel!.configs.bounceOnCenterPanelChange = true
//        panel!.configs.changeCenterPanelAnimated = true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let centerNav = mainStoryBoard.instantiateViewController(withIdentifier: "centerNav") as! UINavigationController
            _ = panel!.center(centerNav)
        case 1:
            let settingsStoryboard = UIStoryboard(name: "Settings2", bundle: nil)
            let centerNav = settingsStoryboard.instantiateInitialViewController() as! UINavigationController
            _ = panel!.center(centerNav)
        case 2:
            let historyStoryboard = UIStoryboard(name: "ExpensesThisMonthViewController", bundle: nil)
            let exp = historyStoryboard.instantiateInitialViewController() as! ExpensesThisMonthViewController
            let centerNav = UINavigationController(rootViewController: exp)
            _ = panel!.center(centerNav)
        case 3:
            let budgetExportsStoryboard = UIStoryboard(name: "BudgetExport", bundle: nil)
            let centerNav = budgetExportsStoryboard.instantiateInitialViewController() as! ExpensesThisMonthViewController
            centerNav.budgets = (try? BudgetForDay.getBudgetsFromDefaults()) ?? []
            _ = panel!.center(centerNav)
        default:
            let converterStoryboard = UIStoryboard(name: "ConvertorViewController", bundle: nil)
            let centerNav = converterStoryboard.instantiateInitialViewController() as! UINavigationController
            _ = panel!.center(centerNav)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFont      = UIFont.init(name: "Helvetica-Light", size: 18.0)
        let headerString    = NSAttributedString(string: "Pages", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6156862745, green: 0.6156862745, blue: 0.6156862745, alpha: 0.8239244435),
                                                                               NSAttributedString.Key.font: headerFont!,
                                                                               NSAttributedString.Key.kern: 0.7])
        
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.attributedText = headerString
        
        label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16.0).isActive                       = true
        label.leadingAnchor.constraint(equalToSystemSpacingAfter: headerView.leadingAnchor, multiplier: 1.0).isActive   = true
        label.heightAnchor.constraint(equalToConstant: 20.0).isActive                                                   = true
        
        
        imageView.contentMode = .scaleAspectFill
        let imageSize: CGFloat = 120.0 //Random magic number
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: imageSize, height: imageSize))
        
        
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: headerView.topAnchor, constant: 50.0).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        titleLabel.text         = "Daily Budget"
        titleLabel.textColor    = .white
        titleLabel.font         = UIFont.boldSystemFont(ofSize: 20.0)
        
        headerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive  = true
        imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive   = true
        imageView.layer.cornerRadius    = imageSize/2
        imageView.layer.masksToBounds   = true

        return headerView
    }

}

extension LeftMenuTableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let y = log(-scrollView.contentOffset.y)/log(20)
        //print(y)
        ///Description
        ///
        ///y = log20(-yOffset)
        /// It grows slowly enough that I like the transformation.
//        if y >= 1 {
//            if y <= 1.3 {
//                imageView.transform = CGAffineTransform(scaleX: y, y: y)
//            }
//        } else {
//            imageView.transform = CGAffineTransform.identity
//        }
        //MARK: Keeping this code because i like it. First time using log in something real😅
        
        let y           = -scrollView.contentOffset.y
        let growth      = y.mapCGFloat(min: 1.0, max: 1.6)
        let movement    = y.mapCGFloat(min: 0.0, max: 100.0)
        imageView.transform     = CGAffineTransform(scaleX: growth, y: growth).concatenating(CGAffineTransform(translationX: 0.0, y: -movement))
        titleLabel.transform    = CGAffineTransform(translationX: 0.0, y: -y)
    }
}

extension CGFloat {
    func mapCGFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        if (0.0...255.0).contains(self) {
            let delta = abs(max - min)
            if self > 0 {
                return self/255.0 * delta + min //starting from min and adding the number of steps (of 255 possible steps) * the delta
            } else {
                return min
            }
            
        } else if self < 0.0 {
            return min
        } else {
            return max
        }
    }

}
