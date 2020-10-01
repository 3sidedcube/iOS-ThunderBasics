//
//  DateFormatter+Extensions.swift
//  ThunderBasics-iOS
//
//  Created by Ben Shutt on 23/01/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

public extension DateFormatter {
    
    /// Standard `iso8601` `DateFormatter`
    /// Note milliseconds included, for customization over `dateFormat`,
    /// see `iso8601Formatter(dateFormat:timeZone:)`
    static var iso8601Millis: DateFormatter {
        return iso8601Formatter(
            dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        )
    }
    
    /// Standard `iso8601` `DateFormatter`
    /// Note milliseconds included, for customization over `dateFormat`,
    /// see `iso8601Formatter(dateFormat:timeZone:)`
    static var iso8601: DateFormatter {
        return iso8601Formatter(
            dateFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        )
    }
    
    /// `DateFormatter` has:
    /// - `.iso8601` `Calendar`
    /// - "en_US_POSIX" `Locale`
    /// - Given `timeZone`, defaults to `TimeZone.current`
    /// - Given `dateFormat`
    /// - Parameters:
    ///   - dateFormat: Given `String` date format
    ///   - timeZone: Given `TimeZone`, defaults to `TimeZone.current`
    static func iso8601Formatter(
        dateFormat: String,
        timeZone: TimeZone? = TimeZone.current
    ) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter
    }
}
