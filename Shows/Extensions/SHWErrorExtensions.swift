//
//  SHWErrorExtensions.swift
//  Shows
//
//  Created by Will Chilcutt on 9/25/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

extension Error
{
    var code    : Int { return (self as NSError).code }
    var domain  : String { return (self as NSError).domain }
}
