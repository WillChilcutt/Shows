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

struct SHWImage : Codable
{
    let medium      : String
    let original    : String
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

/*
 "score": 17.52139,
    "show": {
      "id": 139,
      "url": "http://www.tvmaze.com/shows/139/girls",
      "name": "Girls",
      "type": "Scripted",
      "language": "English",
      "genres": [
        "Drama",
        "Romance"
      ],
      "status": "Ended",
      "runtime": 30,
      "premiered": "2012-04-15",
      "officialSite": "http://www.hbo.com/girls",
      "schedule": {
        "time": "22:00",
        "days": [
          "Sunday"
        ]
      },
      "rating": {
        "average": 6.7
      },
      "weight": 90,
      "network": {
        "id": 8,
        "name": "HBO",
        "country": {
          "name": "United States",
          "code": "US",
          "timezone": "America/New_York"
        }
      },
      "webChannel": null,
      "externals": {
        "tvrage": 30124,
        "thetvdb": 220411,
        "imdb": "tt1723816"
      },
      "image": {
        "medium": "http://static.tvmaze.com/uploads/images/medium_portrait/31/78286.jpg",
        "original": "http://static.tvmaze.com/uploads/images/original_untouched/31/78286.jpg"
      },
      "summary": "<p>This Emmy winning series is a comic look at the assorted humiliations and rare triumphs of a group of girls in their 20s.</p>",
      "updated": 1532343735,
      "_links": {
        "self": {
          "href": "http://api.tvmaze.com/shows/139"
        },
        "previousepisode": {
          "href": "http://api.tvmaze.com/episodes/1079686"
        }
      }
    }
 */
