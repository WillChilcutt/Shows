//
//  SHWEpisode.swift
//  Shows
//
//  Created by Will Chilcutt on 9/19/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

struct SHWEpisode : Codable
{
    let id          : Int
    let url         : String
    let name        : String
    let image       : SHWImage?
    let season      : Int
    let number      : Int
    let runtime     : Int
    let summary     : String?
    let airdate     : String
    let airtime     : String
    let airstamp    : String?
    
    var show        : SHWShow?
    
    var originalDate : Date?
    {   get
        {
            guard let airstamp = self.airstamp else { return nil }
            
            return DateFormatter.iso8601.date(from: airstamp)
        }
    }
}

extension SHWEpisode : Equatable
{
    static func == (lhs: SHWEpisode, rhs: SHWEpisode) -> Bool
    {
        return lhs.show?.id == rhs.show?.id && lhs.id == rhs.id && lhs.season == rhs.season && lhs.number == rhs.number && lhs.name == rhs.name
    }
}

extension SHWEpisode : Hashable
{
    var hashValue: Int
    {
        return self.id
    }
}

extension Array where Element == SHWEpisode
{
    func episodeCatelog() -> [Int : [SHWEpisode]]
    {
        var catelog :  [Int : [SHWEpisode]] = [:]
        
        for episode in self
        {
            if var episodes = catelog[episode.season]
            {
                episodes.append(episode)
                catelog[episode.season] = episodes
            }
            else
            {
                catelog[episode.season] = [episode]
            }
        }
        
        return catelog
    }
    
    func groupByDate() -> [SHWScheduleDay]
    {
        var dateDict :  [Date : [SHWEpisode]] = [:]
        
        for episode in self
        {
            if let date = episode.originalDate?.startOfDay
            {
                if var episodes = dateDict[date]
                {
                    episodes.append(episode)
                    dateDict[date] = episodes
                }
                else
                {
                    dateDict[date] = [episode]
                }
            }
        }
        
        if dateDict.keys.contains(Date().startOfDay) == false
        {
            dateDict[Date().startOfDay] = []
        }
        
        var scheduleDayArray : [SHWScheduleDay] = []
        
        for key in dateDict.keys
        {
            guard let episodes = dateDict[key] else { continue }
            
            let day = SHWScheduleDay(date: key, episodes: episodes)
            
            scheduleDayArray.append(day)
        }
        
        scheduleDayArray.sort
        { (lhs, rhs) -> Bool in
            return lhs.date < rhs.date
        }
        
        return scheduleDayArray
    }
}
