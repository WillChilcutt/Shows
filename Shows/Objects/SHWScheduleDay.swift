//
//  SHWScheduleDay.swift
//  Shows
//
//  Created by Will Chilcutt on 9/21/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

enum SHWScheduleDayFilterType
{
    case watched
}

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
    mutating func filteredBy(filterType : SHWScheduleDayFilterType) -> [SHWScheduleDay]
    {
        var daysToKeep : [SHWScheduleDay] = []
        
        switch filterType
        {
            case .watched:
         
                for scheduleDay in self
                {
                    let episodesNotWatched = scheduleDay.episodes.filter { $0.watched == nil || $0.watched == false }
                    
                    scheduleDay.episodes.removeAll()
                    scheduleDay.episodes.append(contentsOf: episodesNotWatched)
                    
                    if scheduleDay.date.startOfDay == Date().startOfDay || scheduleDay.episodes.isEmpty == false
                    {
                        daysToKeep.append(scheduleDay)
                    }
                }
                
            break
        }
        
       return daysToKeep
    }
}
