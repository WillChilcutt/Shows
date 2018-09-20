//
//  SHWNetwork.swift
//  Shows
//
//  Created by Will Chilcutt on 9/18/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

enum SHWNetworkServer : String, LLNetworkManagerServer
{
    case tvMaze = "http://api.tvmaze.com"
}

enum SHWNetworkRequest :  LLNetworkManagerRequest
{
    case searchShows(withQuery : String)
    case getEpisodes(forShow : SHWShow)
    
    var rawValue: String
    {
        get
        {
            switch self
            {
                case .searchShows(let query):
                    return "/search/shows?q=\(query)"
                case .getEpisodes(let show):
                    return "/shows/\(show.id)/episodes"
            }
        }
    }
}
