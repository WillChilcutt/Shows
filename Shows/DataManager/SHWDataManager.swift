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
            do
            {
                let episodes = try self.getCachedEpisodes(forShow: show)
                
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
    
    func getCachedEpisodes(forShow show : SHWShow) throws -> [SHWEpisode]
    {
        let showEpisodeJSONFilePath = kSHWDataManagerEpisodeStorageLocation(forShow: show)
        
        let episodes = try Disk.retrieve(showEpisodeJSONFilePath,
                                         from: .documents,
                                         as: [SHWEpisode].self,
                                         decoder: JSONDecoder())
        
        return episodes
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
                        for episode in episodesArray
                        {
                            episode.show = show
                        }
                        
                        try self.save(episodes: episodesArray,
                                      forShow: show)
                        
                        completionBlock(.success(withResult:episodesArray))
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
    
    func save(episodes newEpisodes : [SHWEpisode], forShow show : SHWShow, overriding : Bool? = false) throws
    {
        if overriding == false
        {
            let oldWatchedEpisodes = try self.getCachedEpisodes(forShow: show).filter { $0.watched == true }
            
            for watchedEpisode in oldWatchedEpisodes
            {
                watchedEpisode.show = show
                let matchingEpisodes = newEpisodes.filter{ $0 == watchedEpisode }
                guard let newEquivalentEpisode = matchingEpisodes.first else {  continue }
                
                newEquivalentEpisode.watched = watchedEpisode.watched
            }
            
            newEpisodes.forEach { $0.show = show }
        }
        
        let showEpisodeJSONFilePath = kSHWDataManagerEpisodeStorageLocation(forShow: show)

        try Disk.save(newEpisodes,
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
        try Disk.append(show,
                        to: kSHWDataManagerFavoritesStorageLocation,
                        in: .documents)
    }
    
    func unfavoriteShow(_ show : SHWShow) throws
    {
        var favoriteShows = try self.getFavoritedShows()
        
        guard let index = favoriteShows.index(of: show) else { return } //If didn't find show, don't continue

        favoriteShows.remove(at: index)
        
        try Disk.save(favoriteShows,
                      to: .documents,
                      as: kSHWDataManagerFavoritesStorageLocation)

        try Disk.remove(kSHWDataManagerEpisodeStorageLocation(forShow: show),
                        from: .documents)
    }
    
    func isShowFavorited(_ show : SHWShow) throws -> Bool
    {
        return try self.getFavoritedShows().contains(show)
    }
}

//Updating episodes

extension SHWDataManager
{
    func updateEpisodes(_ episodes : [SHWEpisode], forShow show : SHWShow) throws
    {
        for episode in episodes
        {
            try self.updateEpisode(episode, forShow: show)
        }
    }
    
    func updateEpisode(_ episode : SHWEpisode, forShow show : SHWShow) throws
    {
        var episodesArray = try self.getCachedEpisodes(forShow: show)
        
        let filteredEpisodes = episodesArray.filter { $0 == episode}
        
        guard let oldEpisode = filteredEpisodes.first, let index = episodesArray.index(of: oldEpisode) else { return }
        
        episodesArray.remove(at: index) //Remove old
        episodesArray.insert(episode, at: index) //Insert updated
        
        try self.save(episodes: episodesArray, forShow: show, overriding: true)
    }
}
