//
//  ImageColorAnalysisTests.swift
//  ThunderBasicsTests
//
//  Created by Simon Mitchell on 06/07/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import XCTest
import UIKit
@testable import ThunderBasics

extension CGFloat {
    
    func rounded(to places: Int) -> Self {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIColor.RGBAComponents {
    func rounded(to places: Int) -> UIColor.RGBAComponents {
        return .init(
            red: red.rounded(to: places),
            green: green.rounded(to: places),
            blue: blue.rounded(to: places),
            alpha: alpha.rounded(to: places)
        )
    }
}

class ImageColorAnalysisTests: XCTestCase {
    
    func image(named: String, extension resourceExtension: String = "jpg") -> UIImage {
        guard let url = Bundle(for: ImageColorAnalysisTests.self).url(forResource: named, withExtension: resourceExtension) else {
            fatalError("Missing resource in test target: \(named).\(resourceExtension)")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Can't read data in file in test target: \(named).\(resourceExtension)")
        }
        guard let image = UIImage(data: data) else {
            fatalError("Resource: \(named).\(resourceExtension) doesn't contain valid image data")
        }
        return image
    }
    
    func testComplexExamplesPickCorrectColours() {
        
        let jacksonPollockImage = image(named: "jacksonPollock")
        var colorAnalyser = ImageColorAnalyzer(image: jacksonPollockImage)
        colorAnalyser.analyze()
        
        XCTAssertNotNil(colorAnalyser.backgroundColor)
        XCTAssertEqual(colorAnalyser.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.7, green: 0.64, blue: 0.53, alpha: 1))
        XCTAssertEqual(colorAnalyser.primaryColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.85, green: 0.81, blue: 0.72, alpha: 1))
        XCTAssertEqual(colorAnalyser.secondaryColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.91, green: 0.82, blue: 0.16, alpha: 1))
        
        let vincentImage = image(named: "vincent")
        colorAnalyser = ImageColorAnalyzer(image: vincentImage, pixelThreshold: .fixed(1))
        colorAnalyser.analyze()
        
        XCTAssertNotNil(colorAnalyser.backgroundColor)
        XCTAssertEqual(colorAnalyser.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.07, green: 0.33, blue: 0.2, alpha: 1))
        XCTAssertEqual(colorAnalyser.primaryColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.83, green: 0.74, blue: 0.53, alpha: 1))
        XCTAssertEqual(colorAnalyser.secondaryColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.87, green: 0.92, blue: 0.78, alpha: 1))
        XCTAssertEqual(colorAnalyser.detailColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.88, green: 0.72, blue: 0.26, alpha: 1))
    }

    func testFlowersImageWithCalculatedThresholdReturnsValues() {
        
        let flowerImage = image(named: "flowers")
        let colorAnalyser = ImageColorAnalyzer(image: flowerImage, pixelThreshold: .calculated)
        colorAnalyser.analyze()
        
        XCTAssertNotNil(colorAnalyser.backgroundColor)
        XCTAssertEqual(colorAnalyser.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.93, green: 0.53, blue: 0.60, alpha: 1))
    }
    
    func testUseAllPixelsOptionWorksAsExpected() {
        
        let nonEdgeImage = image(named: "nonEdgePrimary", extension: "png")
        let colorAnalyzer = ImageColorAnalyzer(image: nonEdgeImage)
        colorAnalyzer.analyze()

        // We expect to get white here, because none of the edge pixels are non-white
        XCTAssertEqual(colorAnalyzer.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 1, green: 1, blue: 1, alpha: 1))

        let allPixelAnalzer = ImageColorAnalyzer(image: nonEdgeImage, options: [.useAllPixelsForBackgroundColor])
        allPixelAnalzer.analyze()
        XCTAssertEqual(allPixelAnalzer.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.53, green: 0.22, blue: 0.2, alpha: 1))

        let flowerImage = image(named: "flowers")
        let flowerAnalyzer = ImageColorAnalyzer(image: flowerImage, options: [.useAllPixelsForBackgroundColor])
        flowerAnalyzer.analyze()

        XCTAssertNotNil(flowerAnalyzer.backgroundColor)
        XCTAssertEqual(flowerAnalyzer.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.24, green: 0.11, blue: 0.09, alpha: 1))
        
        let arcLogo = image(named: "arcLogo")
        let arcLogoAnalyzer = ImageColorAnalyzer(image: arcLogo, options: [.useAllPixelsForBackgroundColor])
        arcLogoAnalyzer.blackAndWhiteThreshold = 0.14
        arcLogoAnalyzer.analyze()
        
        XCTAssertNotNil(arcLogoAnalyzer.backgroundColor)
        XCTAssertEqual(arcLogoAnalyzer.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.86, green: 0.1, blue: 0.16, alpha: 1))
        XCTAssertEqual(arcLogoAnalyzer.primaryColor?.rgbaComponents?.rounded(to: 2), UIColor.white.rgbaComponents?.rounded(to: 2))
    }
    
    func testColouredBackgroundIsPickedOut() {
        
        let colouredBGImage1 = image(named: "colouredBg", extension: "png")
        let colorAnlyzer1 = ImageColorAnalyzer(image: colouredBGImage1, options: [])
        colorAnlyzer1.analyze()
        
        XCTAssertEqual(colorAnlyzer1.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.07, green: 0.15, blue: 0.35, alpha: 1))
        XCTAssertEqual(colorAnlyzer1.primaryColor?.rgbaComponents?.rounded(to: 2), .init(red: 1, green: 1, blue: 1, alpha: 1))
        
        let colouredBGImage2 = image(named: "3scLogo", extension: "png")
        let colorAnlyzer2 = ImageColorAnalyzer(image: colouredBGImage2, options: [])
        colorAnlyzer2.analyze()
        
        XCTAssertEqual(colorAnlyzer2.backgroundColor?.rgbaComponents?.rounded(to: 2), .init(red: 0.49, green: 1.0, blue: 0.0, alpha: 1))
        XCTAssertEqual(colorAnlyzer2.primaryColor?.rgbaComponents?.rounded(to: 2), UIColor.black.rgbaComponents?.rounded(to: 2))
    }
    
    struct TestCaseResult {
        
        let background: UIColor.RGBAComponents?
        
        let primary: UIColor.RGBAComponents?
        
        let secondary: UIColor.RGBAComponents?
        
        let detail: UIColor.RGBAComponents?
    }
    
    func testBestForLogosAnalyser() {
        
        let cases: [UIImage : TestCaseResult] = [
            image(named: "colouredBg", extension: "png"): .init(
                background: .init(red: 0.07, green: 0.15, blue: 0.35, alpha: 1),
                primary: .init(red: 1, green: 1, blue: 1, alpha: 1),
                secondary: nil,
                detail: nil
            ),
            image(named: "3scLogo", extension: "png"): .init(
                background: .init(red: 0.49, green: 1.0, blue: 0.0, alpha: 1),
                primary: UIColor.black.rgbaComponents,
                secondary: .init(red: 0.25, green: 0.52, blue: 0.0, alpha: 1.0),
                detail: .init(red: 0.38, green: 0.79, blue: 0.0, alpha: 1.0)
            ),
            image(named: "arcLogo"): .init(
                background: .init(red: 0.86, green: 0.1, blue: 0.16, alpha: 1),
                primary: UIColor.white.rgbaComponents,
                secondary: .init(red: 1.0, green: 0.67, blue: 0.7, alpha: 1.0),
                detail: nil
            ),
            image(named: "nonEdgePrimary", extension: "png"): .init(
                background: .init(red: 0.53, green: 0.22, blue: 0.2, alpha: 1),
                primary: UIColor.white.rgbaComponents,
                secondary: nil,
                detail: nil
            ),
            image(named: "camrote", extension: "png"): .init(
                background: .init(red: 0.12, green: 0.14, blue: 0.19, alpha: 1),
                primary: UIColor.white.rgbaComponents,
                secondary: .init(red: 0.98, green: 0.71, blue: 0.25, alpha: 1),
                detail: nil
            ),
            image(named: "nyt"): .init(
                background: UIColor.black.rgbaComponents,
                primary: UIColor.white.rgbaComponents,
                secondary: nil,
                detail: nil
            ),
            image(named: "nebraska"): .init(
                background: .init(red: 0.9, green: 0.23, blue: 0.33, alpha: 1),
                primary: UIColor.white.rgbaComponents,
                secondary: .init(red: 1, green: 0.74, blue: 0.78, alpha: 1),
                detail: nil
            ),
            image(named: "mit", extension: "png"): .init(
                background: .init(red: 0.64, green: 0.12, blue: 0.2, alpha: 1),
                primary: UIColor.white.rgbaComponents,
                secondary: .init(red: 0.87, green: 0.69, blue: 0.72, alpha: 1),
                detail: nil
            )
        ]
        
        cases.forEach { (keyValue) in
            
            let analyser = ImageColorAnalyzer.createFor(logo: keyValue.key)
            analyser.analyze()
            XCTAssertEqual(analyser.backgroundColor?.rgbaComponents?.rounded(to: 2), keyValue.value.background)
            XCTAssertEqual(analyser.primaryColor?.rgbaComponents?.rounded(to: 2), keyValue.value.primary)
            XCTAssertEqual(analyser.secondaryColor?.rgbaComponents?.rounded(to: 2), keyValue.value.secondary)
            XCTAssertEqual(analyser.detailColor?.rgbaComponents?.rounded(to: 2), keyValue.value.detail)
        }
    }
    
    func testDoesntFailWithBlackAndWhiteImage() {
        
        let result = TestCaseResult.init(
            background: UIColor.black.rgbaComponents,
            primary: UIColor.white.rgbaComponents,
            secondary: nil,
            detail: nil
        )
        
        let analyser = ImageColorAnalyzer.createFor(logo: image(named: "nyt"))
        analyser.analyze()
        
        XCTAssertEqual(analyser.backgroundColor?.rgbaComponents?.rounded(to: 2), result.background)
        XCTAssertEqual(analyser.primaryColor?.rgbaComponents?.rounded(to: 2), result.primary)
    }
    
    func testDoesntIgnoreBlackAndWhiteIfGreyscaleImage() {
        
        let result = TestCaseResult.init(
            background: UIColor.black.rgbaComponents,
            primary: UIColor.white.rgbaComponents,
            secondary: nil,
            detail: nil
        )
        
        let analyser = ImageColorAnalyzer.createFor(logo: image(named: "nyt"))
        analyser.analyze()
        
        XCTAssertEqual(analyser.backgroundColor?.rgbaComponents?.rounded(to: 2), result.background)
        XCTAssertEqual(analyser.primaryColor?.rgbaComponents?.rounded(to: 2), result.primary)
    }
}
