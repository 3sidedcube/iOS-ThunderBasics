//
//  CoreSpotlightIndexable.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import CoreSpotlight

/// A protocol which adds core spotlight indexability
public protocol CoreSpotlightIndexable {
    
    /// The searchable attribute set representing the item
    var searchableAttributeSet: CSSearchableItemAttributeSet? { get }
}
