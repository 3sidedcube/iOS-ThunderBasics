//
//  Locale+ISO639_2Tests.swift
//  ThunderBasicsTests
//
//  Created by Ryan Bourne on 06/02/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

@testable import ThunderBasics
import XCTest

class Locale_ISO639_2Tests: XCTestCase {

    func test_localeWithNoLanguageCode_throwsError() {
        let locale = Locale(identifier: "abc")
        
        // Note, while not a valid identifier, Locale internally just returns the identifier as the language code.
        XCTAssertThrowsError(try locale.iso639_2_languageCode(from: ["en": "eng"])) { error in
            XCTAssertEqual(error as! ISO639_2_Error, ISO639_2_Error.NoMatchingLanguageCode)
        }
    }
    
    func test_localeWithLanguageCodeButNoMappedCode_throwsError() {
        let locale = Locale(identifier: "en_gb")
        
        XCTAssertThrowsError(try locale.iso639_2_languageCode(from: ["fr": "fra"])) { error in
            XCTAssertEqual(error as! ISO639_2_Error, ISO639_2_Error.NoMatchingLanguageCode)
        }
    }
    
    func test_localeWithLanguageCodeWithMappedCode_throwsError() {
        let locale = Locale(identifier: "en_gb")
        
        XCTAssert(try locale.iso639_2_languageCode(from: ["en": "eng"]) == "eng")
    }

}
