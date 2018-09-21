//
//  SHWScheduleDay.swift
//  Shows
//
//  Created by Will Chilcutt on 9/21/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

struct SHWScheduleDay : Equatable
{
    let date        : Date
    let episodes    : [SHWEpisode]
    
    static func == (lhs: SHWScheduleDay, rhs: SHWScheduleDay) -> Bool
    {
        return lhs.date == rhs.date
    }
}
