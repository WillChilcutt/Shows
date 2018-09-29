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

private func kSHWDataManagerWatchedEpisodeStorageLocation(forShow show : SHWShow) -> String
{
    return "\(show.id)-watched-episodes.json"
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
    func getFavoritedShows() throws -> [SHWShow]
    {
        let shows = try Disk.retrieve(kSHWDataManagerFavoritesStorageLocation,
                                      from: .documents,
                                      as: [SHWShow].self,
                                      decoder: JSONDecoder())
        
        return shows
    }
    
    func favoriteShow(_ show : SHWShow) throws
    {
        var favoriteShows = try self.getFavoritedShows()
        
        favoriteShows.append(show)
       
        try Disk.save(favoriteShows,
                      to: .documents,
                      as: kSHWDataManagerFavoritesStorageLocation)
    }
    
    func unfavoriteShow(_ show : SHWShow) throws
    {
        var favoriteShows = try self.getFavoritedShows()
        
        guard let index = favoriteShows.index(of: show) else { return } //If didn't find show, don't continue

        favoriteShows.remove(at: index)
        
        try Disk.save(favoriteShows,
                      to: .documents,
                      as: kSHWDataManagerFavoritesStorageLocation)
    }
    
    func isShowFavorited(_ show : SHWShow) throws -> Bool
    {
        return try self.getFavoritedShows().contains(show)
    }
}

//Watched

extension SHWDataManager
{
    func getWatchedEpisodes(forShow show : SHWShow) throws -> [SHWEpisode]
    {
        let location = kSHWDataManagerWatchedEpisodeStorageLocation(forShow: show)
        
        do
        {
            let episodesArray = try Disk.retrieve(location,
                                                  from: .documents,
                                                  as: [SHWEpisode].self,
                                                  decoder: JSONDecoder())
            
            return episodesArray
        }
        catch let error
        {
            print("Failed to get shows: \(error)")
            
            return []
        }
    }
    
    func handleUserHasWatched(episodes episodesArray : [SHWEpisode], forShow show : SHWShow) throws
    {
        var watchedEpisodes = try self.getWatchedEpisodes(forShow: show)
        
        watchedEpisodes.append(contentsOf: episodesArray)
        
        let location = kSHWDataManagerWatchedEpisodeStorageLocation(forShow: show)
        
        try Disk.save(watchedEpisodes,
                      to: .documents,
                      as: location)
    }
    
    func handleUserHasNotWatched(episodes episodesArray : [SHWEpisode], forShow show : SHWShow) throws
    {
        var watchedEpisodes = try self.getWatchedEpisodes(forShow: show)
                
        for episode in episodesArray
        {
            guard let index = watchedEpisodes.index(of: episode) else { continue }
            
            watchedEpisodes.remove(at: index)
        }
        
        let location = kSHWDataManagerWatchedEpisodeStorageLocation(forShow: show)
        
        try Disk.save(watchedEpisodes,
                      to: .documents,
                      as: location)
    }
}
