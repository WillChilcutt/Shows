//
//  SHWDateFormatterExtensions.swift
//  Shows
//
//  Created by Will Chilcutt on 9/21/18.
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
    
    static let justTime : DateFormatter =
    {
       let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        
        return formatter
    }()
}
