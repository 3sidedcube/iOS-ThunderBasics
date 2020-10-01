//
//  DateFormatterExtensionsTests.swift
//  ThunderBasicsTests
//
//  Created by Ben Shutt on 04/05/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

@testable import ThunderBasics
import XCTest

class DateFormatterExtensionsTests: XCTestCase {
    
    /// Monday, 04-May-20 16:05:15 UTC
    private lazy var date: Date = {
        let epochTime: TimeInterval = 1588608315.453
        return Date(timeIntervalSince1970: epochTime)
    }()
    
    func testISO8601Millis() {
        XCTAssertEqual(
            DateFormatter.iso8601Formatter(
                dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                timeZone: TimeZone(secondsFromGMT: 7200)
            ).string(from: date),
            "2020-05-04T18:05:15.453+02:00"
        )
    }
    
    func testISO8601() {
        XCTAssertEqual(
            DateFormatter.iso8601Formatter(
                dateFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                timeZone: TimeZone(secondsFromGMT: 3600)
            ).string(from: date),
            "2020-05-04T17:05:15+01:00"
        )
    }
    
    func testISO8601Date() {
        XCTAssertEqual(
            DateFormatter.iso8601Formatter(
                dateFormat: "yyyy-MM-dd",
                timeZone: TimeZone(secondsFromGMT: 3600)
            ).string(from: date),
            "2020-05-04"
        )
    }
}
