//
//  SHWShow.swift
//  Shows
//
//  Created by Will Chilcutt on 9/18/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

struct SHWShowSearchResult : Codable
{
    let show    : SHWShow
    let score   : Double
}

struct SHWShow : Codable
{
    let id              : Int
    let url             : String
    let name            : String
    let type            : String
    let image           : SHWImage?
    let genres          : [String]
    let rating          : SHWShowRating
    let status          : SHWShowStatus
    let weight          : Int
    let network         : SHWNetwork?
    let updated         : Int
    let runtime         : Int?
    let summary         : String?
    let language        : String
    let schedule        : SHWShowSchedule
    let externals       : SHWExternalResources
    let premiered       : String?
    let officialSite    : String?
}

extension SHWShow : Equatable
{
    static func == (lhs: SHWShow, rhs: SHWShow) -> Bool
    {
        return lhs.id == rhs.id
    }
}

enum SHWShowStatus : String, Codable
{
    case ended          = "Ended"
    case running        = "Running"
    case inDevelopment  = "In Development"
    case toBeDetermined = "To Be Determined"
}

struct SHWShowSchedule : Codable
{
    let time : String
    let days : [String]
}

struct SHWShowRating : Codable
{
    let average : Double?
}

struct SHWCountry : Codable
{
    let name        : String
    let code        : String
    let timezone    : String
}

struct SHWNetwork : Codable
{
    let id      : Int
    let name    : String
    let country : SHWCountry
}

struct SHWExternalResources : Codable
{
    let imdb    : String?
    let tvrage  : Int?
    let thetvdb : Int?
}
