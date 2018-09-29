//
//  SHWScheduleDay.swift
//  Shows
//
//  Created by Will Chilcutt on 9/21/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

class SHWScheduleDay : Equatable
{
    let date        : Date
    var episodes    : [SHWEpisode] = []
    
    init(date: Date, episodes: [SHWEpisode])
    {
        self.date       = date
        self.episodes   = episodes
    }
    
    static func == (lhs: SHWScheduleDay, rhs: SHWScheduleDay) -> Bool
    {
        return lhs.date == rhs.date
    }
}

extension Array where Element == SHWScheduleDay
{
    mutating func filteredBy(watchedEpisodes : [SHWShow:[SHWEpisode]])
    {
        var daysToKeep : [SHWScheduleDay] = []
        
        for scheduleDay in self
        {
            var episodesNotWatched : [SHWEpisode] = []
            
            for episode in scheduleDay.episodes
            {
                guard let show = episode.show else { continue }

                print("Checking to see if \(show.name) - \(episode.season) - \(episode.number) has been watched")
                
                if  let showWatchedEpisodes = watchedEpisodes[show],
                    showWatchedEpisodes.contains(episode) == false
                {
                    episodesNotWatched.append(episode)
                }
            }
            
            scheduleDay.episodes.removeAll()
            scheduleDay.episodes.append(contentsOf: episodesNotWatched)
            
            if scheduleDay.date.startOfDay == Date().startOfDay || scheduleDay.episodes.isEmpty == false
            {
                daysToKeep.append(scheduleDay)
            }
        }
        
        self.removeAll()
        self.append(contentsOf: daysToKeep)
    }
}
