//
//  AppDelegate.swift
//  Shows
//
//  Created by Will Chilcutt on 9/18/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

private struct SHWTabBarRep
{
    let title               : String
    let viewController      : UIViewController
    let tabBarImage         : UIImage
    let selectedTabBarImage : UIImage
}

private let kAppDelegateBackgroundFetchInterval = TimeInterval(60 * 60)  //1 hours worth of seconds
private let kAppDelegateBackgroundNewEpisodesNotificationId = "kAppDelegateBackgroundNewEpisodesNotificationId"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        UIApplication.shared.setMinimumBackgroundFetchInterval(kAppDelegateBackgroundFetchInterval)
        
        self.requestLocalPushNotificationsPermission()
        
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
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        let dataManager = SHWDataManager()
        guard let favoriteShows = try? dataManager.getFavoritedShows() else { print("Failed to get favorite shows "); completionHandler(.failed); return }
        
        dataManager.getEpisodes(forShows: favoriteShows,
                                withCompletionBlock:
        { (response) in
            switch response
            {
                case .failure(_):
                    completionHandler(.failed)
                    break
                case .success(let cachedEpisodesArray):
                    
                    dataManager.getEpisodes(forShows: favoriteShows,
                                            freshDataOnly: true,
                                            withCompletionBlock:
                    { (response) in
                        switch response
                        {
                            case .failure(_):
                                completionHandler(.failed)
                                break
                            case .success(let freshEpisodesArray):
            
                                if cachedEpisodesArray == freshEpisodesArray
                                {
                                    print("No new data")
                                                                        
                                    completionHandler(.noData)
                                }
                                else
                                {
                                    print("New data!")
                                    
                                    let difference = cachedEpisodesArray.difference(from: freshEpisodesArray);
                                    
                                    if difference.count > 0
                                    {
                                        self.sendLocalNotifications(forNewEpisodes: difference)
                                    }
                                    
                                    completionHandler(.newData)
                                }
                                
                                break
                        }
                    })
                    
                    break
            }
        })
    }
    
    private func sendLocalNotifications(forNewEpisodes episodesArray : [SHWEpisode])
    {
        var showsSet : Set<SHWShow> = Set()
        
        for episode in episodesArray
        {
            guard let show = episode.show else { continue }
            showsSet.insert(show)
        }
        
        var pushNotificationBody : String = "There are new episodes available for "
        
        let arrayOfShowsWithNewEpisodes = Array(showsSet)
        
        for show in arrayOfShowsWithNewEpisodes
        {
            if  arrayOfShowsWithNewEpisodes.count != 1 &&
                show != arrayOfShowsWithNewEpisodes.first
            {
                if show == arrayOfShowsWithNewEpisodes.last
                {
                    pushNotificationBody.append(", & ")
                }
                else
                {
                    pushNotificationBody.append(", ")
                }
            }
            
            pushNotificationBody.append(show.name)
        }
        
        pushNotificationBody.append("!")
        
        let content = UNMutableNotificationContent()
        content.title = "New shows available!"
        content.body = pushNotificationBody
        content.sound = UNNotificationSound.default()
        
        let notificationRequest = UNNotificationRequest(identifier: kAppDelegateBackgroundNewEpisodesNotificationId,
                                                        content: content,
                                                        trigger:nil)
        
        UNUserNotificationCenter.current().add(notificationRequest,
                                               withCompletionHandler: nil)
    }
    
    private func requestLocalPushNotificationsPermission()
    {
        let requestAuthorizationsOptions : UNAuthorizationOptions = [.alert, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: requestAuthorizationsOptions)
        { (granted, error) in
            
        }
    }
}

