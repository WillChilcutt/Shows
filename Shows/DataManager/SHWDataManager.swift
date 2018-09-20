//
//  SHWDataManager.swift
//  Shows
//
//  Created by Will Chilcutt on 9/19/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit
import Disk

private let kSHWDataManagerFavoritesStorageLocation = "favorites.json"

class SHWDataManager: NSObject
{
    class func getFavoritedShows() -> [SHWShow]
    {
        do
        {
            let shows = try Disk.retrieve(kSHWDataManagerFavoritesStorageLocation,
                                          from: .documents,
                                          as: [SHWShow].self,
                                          decoder: JSONDecoder())
            
            return shows
        }
        catch let error
        {
            print("Failed to get shows: \(error)")
            
            return []
        }
    }
    
    class func favoriteShow(_ show : SHWShow)
    {
        var favoriteShows = self.getFavoritedShows()
        
        favoriteShows.append(show)
        
        do
        {
            try Disk.save(favoriteShows,
                          to: .documents,
                          as: kSHWDataManagerFavoritesStorageLocation)
        }
        catch let error
        {
            print("Failed to favorite show: \(error)")
        }
    }
    
    class func unfavoriteShow(_ show : SHWShow)
    {
        var favoriteShows = self.getFavoritedShows()
        
        guard let index = favoriteShows.index(of: show) else { return } //If didn't find show, don't continue

        favoriteShows.remove(at: index)
        
        do
        {
            try Disk.save(favoriteShows,
                          to: .documents,
                          as: kSHWDataManagerFavoritesStorageLocation)
        }
        catch let error
        {
            print("Failed to favorite show: \(error)")
        }
    }
    
    class func isShowFavorited(_ show : SHWShow) -> Bool
    {
        return self.getFavoritedShows().contains(show)
    }
}
