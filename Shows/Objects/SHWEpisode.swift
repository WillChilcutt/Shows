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
    let airstamp    : String
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
