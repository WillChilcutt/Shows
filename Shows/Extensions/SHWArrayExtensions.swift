//
//  SHWArrayExtensions.swift
//  Shows
//
//  Created by Will Chilcutt on 9/25/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

extension Array where Element: Hashable
{
    func difference(from other: [Element]) -> [Element]
    {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
