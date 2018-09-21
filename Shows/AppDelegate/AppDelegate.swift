//
//  AppDelegate.swift
//  Shows
//
//  Created by Will Chilcutt on 9/18/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit
import CoreData

private struct SHWTabBarRep
{
    let title               : String
    let viewController      : UIViewController
    let tabBarImage         : UIImage
    let selectedTabBarImage : UIImage
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        LLNetworkManager.sharedInstance.setUp(withServer: SHWNetworkServer.tvMaze)
        
        let tabBarController = UITabBarController()
        
        let scheduleTabBarRep = SHWTabBarRep(title: kSHWFavoritesScheduleViewControllerTitle, viewController: SHWFavoritesScheduleViewController(), tabBarImage: #imageLiteral(resourceName: "schedule"), selectedTabBarImage: #imageLiteral(resourceName: "schedule"))
        let favoritesTabBarRep = SHWTabBarRep(title: kSHWFavoritesViewControllerTitle, viewController: SHWFavoritesViewController(), tabBarImage: #imageLiteral(resourceName: "Favorite"), selectedTabBarImage: #imageLiteral(resourceName: "Favorited"))
        
        for rep in [scheduleTabBarRep,favoritesTabBarRep]
        {
            let navigationController = UINavigationController(rootViewController: rep.viewController)
            navigationController.navigationBar.isTranslucent = false
            rep.viewController.tabBarItem = UITabBarItem(title: rep.title, image: rep.tabBarImage, selectedImage: rep.selectedTabBarImage)
            
            tabBarController.addChildViewController(navigationController)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}

