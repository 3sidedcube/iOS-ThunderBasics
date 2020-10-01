//
//  Locale+ISO639_2.swift
//  ThunderBasics
//
//  Created by Ryan Bourne on 04/02/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// Details the different types of error that may occur while converting the language codes.
///
/// - NoBaseLanguageCode: For some reason, the locale object didn't have an ISO639-1 language code.
/// - NoMatchingLanguageCode: Mapping the ISO639-1 language code to the correct ISO639-2 language code failed, as no match was available.
enum ISO639_2_Error: LocalizedError {
    case NoBaseLanguageCode
    case NoMatchingLanguageCode
}

extension Locale {
    
    /// Provides the mapping from ISO639-1 to ISO639-2 language codes, so Locale language codes can be converted.
    public static var iso639_2Dictionary: [String: String]? = {
        guard let bundleURL = Bundle(identifier: "com.threesidedcube.ThunderBasics")?.url(forResource: "iso639_2", withExtension: "bundle") else {
            return nil
        }
        
        guard let plistURL = Bundle(url: bundleURL)?.url(forResource: "iso639_1_to_iso639_2", withExtension: "plist") else {
            return nil
        }
        
        guard let plistContents = try? PropertyListDecoder().decode([String: String].self, from: Data(contentsOf: plistURL)) else {
            return nil
        }
        
        return plistContents
    }()
    
    /// Determines the ISO639-2 language code for the locale.
    ///
    /// - Parameter mapping: The mapping dictionary that should be used. This should only be overriden from the default while in testing.
    /// - Returns: The ISO639-2 language code, if one is available.
    /// - Throws: An ISO639_2_Error, if the language code is unavailable.
    public func iso639_2_languageCode(from mapping: [String: String]? = Locale.iso639_2Dictionary) throws -> String {
        guard let iso639_1_languageCode = self.languageCode else {
            throw ISO639_2_Error.NoBaseLanguageCode
        }
        
        guard let iso639_2_languageCode = mapping?[iso639_1_languageCode] else {
            throw ISO639_2_Error.NoMatchingLanguageCode
        }
        
        return iso639_2_languageCode
    }
    
}
