//
//  SHWEpisode.swift
//  Shows
//
//  Created by Will Chilcutt on 9/19/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

extension DateFormatter
{
    static let iso8601 : DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        return formatter
    }()
    
    static let prettyPrint : DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, y"
        
        return formatter
    }()
}

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
    
    var originalDate : Date?
    {   get
        {
            guard let airstamp = self.airstamp else { return nil }
            
            return DateFormatter.iso8601.date(from: airstamp)
        }
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
}
