//
//  AppDelegate.swift
//  Budget
//
//  Created by Tudor Croitoru on 04.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        let storyboard = UIStoryboard(name: "Launch Screen Thing", bundle: nil)
//        let splashScreenVC = storyboard.instantiateInitialViewController() as! UINavigationController
//        self.window?.rootViewController = splashScreenVC
//        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialVC = homeStoryboard.instantiateInitialViewController() as! UINavigationController
//        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
//            self.window?.rootViewController?.present(initialVC, //THIS WORKS
//                                                     animated: false,
//                                                     completion: nil)
//        }
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.1041769013, green: 0.2801864147, blue: 0.4007718563, alpha: 1)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        var successfullyOpenedDocument = true
        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = homeStoryboard.instantiateInitialViewController() as! UINavigationController
        self.window?.rootViewController = initialVC
        let documentStoryboard = UIStoryboard(name: "BudgetExport", bundle: nil)
        let documentViewController = documentStoryboard.instantiateInitialViewController() as! BudgetExportViewController
        documentViewController.document = BudgetExportDocument(fileURL: url)
        documentViewController.document?.open(completionHandler: { success in
            if success {
                
                self.window?.rootViewController?.show(documentViewController, sender: nil)
                documentViewController.title = documentViewController.document?.localizedName
            } else {
                print("Error opening file from Files App")
            }
            
            successfullyOpenedDocument = success
        })
        
        return successfullyOpenedDocument
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

