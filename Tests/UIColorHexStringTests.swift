//
//  UIColorHexStringTests.swift
//  ThunderBasicsTests
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import XCTest
#if os(macOS)
import AppKit
typealias UIColor = NSColor
#endif

class UIColorHexStringTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThreeComponentInitialises() {
        let color = UIColor(hexString: "FFF")
        XCTAssertNotNil(color, "FFF not initialized correctly")
    }

    func testFourComponentInitialises() {
        let color = UIColor(hexString: "FFFF")
        XCTAssertNotNil(color, "FFFF not initialized correctly")
    }
    
    func testSixComponentInitialises() {
        let color = UIColor(hexString: "FFFFFF")
        XCTAssertNotNil(color, "FFFFFF not initialized correctly")
    }
    
    func testEightComponentInitialises() {
        let color = UIColor(hexString: "FFFFFFFF")
        XCTAssertNotNil(color, "FFFFFFFF not initialized correctly")
    }
    
    func testWhiteAllocatesCorrectly() {
        
        #if os(macOS)
        let threePartWhite = UIColor(hexString: "FFF")?.usingColorSpace(.genericGray)
        let fourPartWhite = UIColor(hexString: "FFFF")?.usingColorSpace(.genericGray)
        let sixPartWhite = UIColor(hexString: "FFFFFF")?.usingColorSpace(.genericGray)
        let eightPartWhite = UIColor(hexString: "FFFFFFFF")?.usingColorSpace(.genericGray)
        #else
        let threePartWhite = UIColor(hexString: "FFF")
        let fourPartWhite = UIColor(hexString: "FFFF")
        let sixPartWhite = UIColor(hexString: "FFFFFF")
        let eightPartWhite = UIColor(hexString: "FFFFFFFF")
        #endif
        var white: CGFloat = 0.0
        threePartWhite?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 1.0, accuracy: 0.01)
        
        fourPartWhite?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 1.0, accuracy: 0.01)
        
        
        sixPartWhite?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 1.0, accuracy: 0.01)
        
        eightPartWhite?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 1.0, accuracy: 0.01)
    }
    
    func testBlackAllocatesCorrectly() {
        
        #if os(macOS)
        let threePartBlack = UIColor(hexString: "000")?.usingColorSpace(.genericGray)
        let fourPartBlack = UIColor(hexString: "0000")?.usingColorSpace(.genericGray)
        let sixPartBlack = UIColor(hexString: "000000")?.usingColorSpace(.genericGray)
        let eightPartBlack = UIColor(hexString: "00000000")?.usingColorSpace(.genericGray)
        #else
        let threePartBlack = UIColor(hexString: "000")
        let fourPartBlack = UIColor(hexString: "0000")
        let sixPartBlack = UIColor(hexString: "000000")
        let eightPartBlack = UIColor(hexString: "00000000")
        #endif
        
        var white: CGFloat = 0.0
        threePartBlack?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 0.0, accuracy: 0.01)
        
        fourPartBlack?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 0.0, accuracy: 0.01)
        
        sixPartBlack?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 0.0, accuracy: 0.01)
        
        eightPartBlack?.getWhite(&white, alpha: nil)
        XCTAssertEqual(white, 0.0, accuracy: 0.01)
    }
    
    func testRedAllocatesCorrectly() {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        let threePartRed = UIColor(hexString: "F00")
        threePartRed?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        let fourPartRed = UIColor(hexString: "0F00")
        fourPartRed?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
        
        let sixPartRed = UIColor(hexString: "FF0000")
        sixPartRed?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        let eightPartRed = UIColor(hexString: "00FF000000")
        eightPartRed?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }
    
    func testGreenAllocatesCorrectly() {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        let threePartGreen = UIColor(hexString: "0F0")
        threePartGreen?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        let fourPartGreen = UIColor(hexString: "00F0")
        fourPartGreen?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
        
        let sixPartGreen = UIColor(hexString: "00FF00")
        sixPartGreen?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        let eightPartGreen = UIColor(hexString: "0000FF00")
        eightPartGreen?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
    }
    
    func testBlueAllocatesCorrectly() {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        let threePartBlue = UIColor(hexString: "00F")
        threePartBlue?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        let fourPartBlue = UIColor(hexString: "000F")
        fourPartBlue?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
        
        let sixPartBlue = UIColor(hexString: "0000FF")
        sixPartBlue?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        let eightPartBlue = UIColor(hexString: "000000FF")
        eightPartBlue?.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
    }
    
    func testAlpaAllocatesCorrectly() {
        
        var a: CGFloat = 0.0
        
        var fourPart = UIColor(hexString: "f000")
        fourPart?.getRed(nil, green: nil, blue: nil, alpha: &a)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        var eightPart = UIColor(hexString: "FF000000")
        eightPart?.getRed(nil, green: nil, blue: nil, alpha: &a)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
        
        fourPart = UIColor(hexString: "a000")
        fourPart?.getRed(nil, green: nil, blue: nil, alpha: &a)
        XCTAssertEqual(a, 170.0/255.0, accuracy: 0.01)
        
        eightPart = UIColor(hexString: "AA000000")
        eightPart?.getRed(nil, green: nil, blue: nil, alpha: &a)
        XCTAssertEqual(a, 170.0/255.0, accuracy: 0.01)
    }
}
