//
//  SHWGetShowsScheduleRequest.swift
//  Shows
//
//  Created by Will Chilcutt on 9/20/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

class SHWGetShowsScheduleRequest: NSObject
{
    private let showsArray : [SHWShow]
    
    private let dispatchGroup : DispatchGroup = DispatchGroup()
    
    init(withShows shows : [SHWShow])
    {
        self.showsArray = shows
        super.init()
    }
    
    func performRequest(withCompletionBlock completionBlock : @escaping kLLNetworkManagerResultResponseBlock<[SHWEpisode]>)
    {
        for _ in self.showsArray
        {
            self.dispatchGroup.enter()
        }
        
        var episodesArray : [SHWEpisode] = []
        
        for show in self.showsArray
        {
            LLNetworkManager.sharedInstance.performRequest(SHWNetworkRequest.getEpisodes(forShow: show),
                                                           withResultType: [SHWEpisode].self,
                                                           andCompletionBlock:
                
            { (response) in
                
                defer
                {
                    self.dispatchGroup.leave()
                }
                
                switch response
                {
                    case .failure(let error):
                        print("Error getting episdoes for \(show.name): \(error)")
                        break
                    case .success(let results):
                        
                        var resultsWithShow : [SHWEpisode] = []
                        
                        for var episode in results
                        {
                            episode.show = show
                            
                            resultsWithShow.append(episode)
                        }

                        episodesArray.append(contentsOf: resultsWithShow)
                        
                        break
                }
            })
        }
        
        self.dispatchGroup.notify(queue: DispatchQueue.global(qos: .background))
        {
            completionBlock(.success(withResult:episodesArray))
        }
    }
}
