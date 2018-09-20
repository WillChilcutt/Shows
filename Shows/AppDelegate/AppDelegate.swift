//
//  AppDelegate.swift
//  Shows
//
//  Created by Will Chilcutt on 9/18/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        LLNetworkManager.sharedInstance.setUp(withServer: SHWNetworkServer.tvMaze)
        
        let vc = SHWFavoritesViewController()

        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isTranslucent = false
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController        
        window?.makeKeyAndVisible()
        
        return true
    }
}

