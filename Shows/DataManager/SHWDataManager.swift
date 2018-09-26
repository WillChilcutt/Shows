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

private func kSHWDataManagerEpisodeStorageLocation(forShow show : SHWShow) -> String
{
    return "\(show.id)-episodes.json"
}

class SHWDataManager: NSObject
{
    private let dispatchGroup : DispatchGroup = DispatchGroup()

}

//Episodes
extension SHWDataManager
{
    func getEpisodes(forShow show : SHWShow, freshDataOnly : Bool? = false, withCompletionBlock completionBlock : @escaping kLLNetworkManagerResultResponseBlock<[SHWEpisode]>)
    {
        if freshDataOnly == true
        {
            self.getFreshEpisodes(forShow: show,
                                  withCompletionBlock: completionBlock)
        }
        else
        {
            let showEpisodeJSONFilePath = kSHWDataManagerEpisodeStorageLocation(forShow: show)
            
            do
            {
                let episodes = try Disk.retrieve(showEpisodeJSONFilePath,
                                                 from: .documents,
                                                 as: [SHWEpisode].self,
                                                 decoder: JSONDecoder())
                
                completionBlock(.success(withResult:episodes))
            }
            catch let error
            {
                if  error.domain == Disk.errorDomain &&
                    error.code == Disk.ErrorCode.noFileFound.rawValue
                {
                    print("No cached episode data for \(show.name)")
                    self.getFreshEpisodes(forShow: show,
                                          withCompletionBlock: completionBlock)
                }
                else
                {
                    completionBlock(.failure(withError:error))
                }
            }
        }
    }
    
    private func getFreshEpisodes(forShow show : SHWShow, withCompletionBlock completionBlock : @escaping kLLNetworkManagerResultResponseBlock<[SHWEpisode]>)
    {
        LLNetworkManager.sharedInstance.performRequest(SHWNetworkRequest.getEpisodes(forShow: show),
                                                       withResultType: [SHWEpisode].self,
                                                       andCompletionBlock:
        { (response) in
            
            switch response
            {
                case .failure(_):
                    completionBlock(response)
                    break
                case .success(let episodesArray):
                    
                    do
                    {
                        var resultsWithShow : [SHWEpisode] = []
                        
                        for var episode in episodesArray
                        {
                            episode.show = show
                            
                            resultsWithShow.append(episode)
                        }
                        
                        try self.save(episodes: resultsWithShow,
                                      forShow: show)
                        
                        completionBlock(.success(withResult:resultsWithShow))
                    }
                    catch let error
                    {
                        completionBlock(.failure(withError:error))
                    }
                    break
                }
        })
    }
    
    func getEpisodes(forShows showsArray : [SHWShow], freshDataOnly : Bool? = false, withCompletionBlock completionBlock : @escaping kLLNetworkManagerResultResponseBlock<[SHWEpisode]>)
    {
        var allEpisodesArray : [SHWEpisode] = []
        
        for show in showsArray
        {
            self.dispatchGroup.enter()

            self.getEpisodes(forShow: show,
                             freshDataOnly:freshDataOnly)
            { (response) in
                
                defer
                {
                    self.dispatchGroup.leave()
                }
                
                switch response
                {
                    case .failure(let error):
                        print("Error getting episodes for \(show.name): \(error)")
                        break
                    case .success(let episodesArray):
                        allEpisodesArray.append(contentsOf: episodesArray)
                        break
                }
            }
        }
        
        self.dispatchGroup.notify(queue: DispatchQueue.global(qos: .background))
        {
            completionBlock(.success(withResult:allEpisodesArray))
        }
    }
    
    private func save(episodes : [SHWEpisode], forShow show : SHWShow) throws
    {
        let showEpisodeJSONFilePath = kSHWDataManagerEpisodeStorageLocation(forShow: show)

        try Disk.save(episodes,
                      to: .documents,
                      as: showEpisodeJSONFilePath)
    }
}

//Favorites

extension SHWDataManager
{
    func getFavoritedShows() -> [SHWShow]
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
    
    func favoriteShow(_ show : SHWShow)
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
    
    func unfavoriteShow(_ show : SHWShow)
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
    
    func isShowFavorited(_ show : SHWShow) -> Bool
    {
        return self.getFavoritedShows().contains(show)
    }
}
