//
//  String+Extensions.swift
//  ThunderBasics-iOS
//
//  Created by Ben Shutt on 23/01/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

public extension String {
    
    /// Return a new `String` with the first letter capitalized
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    /// Capitalize the first letter of this `String`
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
