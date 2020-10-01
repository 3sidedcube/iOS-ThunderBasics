//
//  ImageColorAnalyzer.h
//  ColorArt
//
// Redistribution and use, with or without modification, are permitted provided that the following conditions are met:
//
// - Redistributions must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
// - Neither the name of Panic Inc nor the names of its contributors may be used to endorse or promote works derived from this software without specific prior written permission from Panic Inc.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL PANIC INC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Modified by David Schimon 1 / 2013
// Modified by Simon Mitchell 02 / 10 / 2018

import UIKit

//MARK: - ImageColorAnalyzer -

/// `ImageColorAnalyzer` Analyzes a `UIImage` and picks out its main colors
public final class ImageColorAnalyzer {
    
    /// Options set to be used with for configuring `ImageColorAnalyzer`'s behaviour
    public struct Options: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Whether to use all of the image's pixels to calculate the background colour.
        /// This is useful if you know that your image's background colour may not be on the lhs edge
        /// of the image which is the default place `ImageColorAnalyzer` checks.
        public static let useAllPixelsForBackgroundColor = Options(rawValue: 1 << 0)
        
        /// Whether to make sure the calculated text colours have a minimum saturation value of 0.15
        public static let increaseTextColourSaturation = Options(rawValue: 1 << 1)
    }
    
    /// An enumeration representing the pixel threshold to use when analysing the image
    public enum PixelThreshold {
        case calculated
        case fixed(Int)
    }
    
    /// Returns an image color analyzer optimised for pulling images from logos
    /// - Parameter image: The image to analyse
    /// - Returns: An instance of `ImageColorAnalyzer`
    public static func createFor(logo image: UIImage) -> ImageColorAnalyzer {
        // - Use all pixels for background color makes sure logos which have a white
        // background don't produce useless results.
        // - `calculated` pixel threshold means the pixel threshold will adjust to the size
        // of the icon provided
        let analyser = ImageColorAnalyzer(
            image: image,
            options: [.useAllPixelsForBackgroundColor],
            pixelThreshold: .calculated
        )
        
        // Bumping this slightly ensures that logos with grey shadows (like the ARC logo)
        // don't have any of the greys in the shadow picked rather than any prominent colour
        // in the logo itself.
        analyser.blackAndWhiteThreshold = 0.14
        
        // Set this quite low because quite often icons are a single large background colour
        // with a small amount of another colour.
        analyser.subsequentColorRatioThreshold = 0.075
        
        return analyser
    }
    
    public var options: Options
    
    /// The image that is being Analyzed
    public var image: UIImage
    
    /// A `UIColor` that represents the main color in the image
    /// e.g. If red is most prominent color in the image the primary color will be red
    public var primaryColor: UIColor?
    
    /// A `UIColor` that represents the secondary color in the image
    /// e.g. If red is the second most prominent color in the image the secondary color will be red
    public var secondaryColor: UIColor?
    
    /// The color of the text that should overlay the image. This color will normally be black or white
    public var detailColor: UIColor?
    
    /// The background color from the image, picked from
    public var backgroundColor: UIColor?
    
    /// The pixel threshold to use for picking colours. If provided as `nil` this will be calculated from
    /// the image's size.
    public var pixelThreshold: PixelThreshold
    
    /// The alpha threshold for picked colours, defaults to `0.2`
    public var alphaThreshold: CGFloat = 0.2
    
    /// The threshold a colour must be away from black or white to be favourably
    /// picked. This is a fractional value, so should be between 0 and 1.
    /// defaults to 0.09
    public var blackAndWhiteThreshold: CGFloat = 0.09
    
    /// Defines the ratio of the next picked colour to the previous most widely
    /// found colour that is required to return a colour in the results.
    /// defaults to 0.3, but this is quite agressive and we suggest setting it lower
    public var subsequentColorRatioThreshold: CGFloat = 0.3
    
    /// Initializes the `ImageColorAnalyzer` with a `UIImage`
    ///
    /// The image will not be analyzed until the `analyze` method is called
    ///
    /// - Parameter image: The `UIImage` to be color analyzed.
    /// - Parameter options: Options to be used when performing colour analysis
    /// - Parameter pixelThreshold: The threshold to use for picking a colour, this defaults to 2. Set to `nil` to have
    /// a value calculated from the image size
    public init(image: UIImage, options: Options = [.increaseTextColourSaturation], pixelThreshold: PixelThreshold = .fixed(2)) {
        self.image = image
        self.pixelThreshold = pixelThreshold
        self.options = options
    }
    
    /// Performs the image analysis
    public func analyze() {
        
        let colourColours = findEdgeColourIn(image)
        backgroundColor = colourColours?.color
        
        guard let colours = colourColours?.colours, let backgroundColor = backgroundColor else {
            return
        }
        let textColours = findTextColours(colours, backgroundColor: backgroundColor)
        primaryColor = textColours?.primary
        secondaryColor = textColours?.secondary
        detailColor = textColours?.detail
    }
    
    private func findEdgeColourIn(_ image: UIImage) -> (color: UIColor?, colours: NSCountedSet?)? {
        
        guard let imageRef = image.cgImage else {
            return nil
        }
        
        let pixelsWide = imageRef.width
        let pixelsHigh = imageRef.height
        
        let imageColours = NSCountedSet(capacity: pixelsHigh * pixelsWide)
        let leftEdgeColours = NSCountedSet(capacity: pixelsHigh)
        
        // Values are hard-coded because this is what we want to convert the image to,
        // not what the original image IS
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * pixelsWide
        let bitsPerComponent = 8
        
        var rawData = [UInt8](repeating: 0, count: Int(pixelsHigh * pixelsWide * bytesPerPixel))
        
        guard let context = CGContext(
            data: &rawData,
            width: pixelsWide,
            height: pixelsHigh,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return nil
        }
        
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: pixelsHigh, height: pixelsWide))
        
        var isGrayscaleImage: Bool = true
        let dontUseAllPixelsForBgColor = !options.contains(.useAllPixelsForBackgroundColor)
        
        for x in 0..<pixelsWide {
            
            let leftEdge = x == 0
            
            for y in 0..<pixelsHigh {
                
                let byteIndex = (bytesPerRow * y) + x * bytesPerPixel
                
                // Because we use `premultipliedLast` we have to get alpha and divide each component by alpha
                let alpha = CGFloat(rawData[byteIndex + 3]) / 255.0
                let red = CGFloat(rawData[byteIndex]) / (alpha * 255.0)
                let green = CGFloat(rawData[byteIndex + 1]) / (alpha * 255.0)
                let blue = CGFloat(rawData[byteIndex + 2]) / (alpha * 255.0)
                
                // Only do this check if not already marked as coloured image
                if isGrayscaleImage && (red, green) != (green, blue) {
                    isGrayscaleImage = false
                }
                
                guard alpha > alphaThreshold else {
                    continue
                }
                
                let colour = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                
                // Don't bother adding them to array if we aren't going to use them!
                if leftEdge && dontUseAllPixelsForBgColor {
                    leftEdgeColours.add(colour)
                }
                
                imageColours.add(colour)
            }
        }
        
        let threshold: Int
        
        switch pixelThreshold {
        case .calculated:
            threshold = Int(CGFloat(pixelsHigh) * 0.01)
        case .fixed(let thresh):
            threshold = thresh
        }
        
        let backgroundColors = options.contains(.useAllPixelsForBackgroundColor) ? imageColours : leftEdgeColours
        
        var countedColours: [(UIColor, Int)] = backgroundColors.compactMap({
            guard let colour = $0 as? UIColor else {
                return nil
            }
            let count = backgroundColors.count(for: colour)
            // Prevent using random colours, threshold should be based in input image size
            guard count > threshold else {
                return nil
            }
            return (colour, count)
        })
        
        countedColours.sort(by: { (pair1, pair2) -> Bool in
            return pair1.1 > pair2.1
        })
        
        guard var proposedEdgeColour = countedColours.first else {
            return nil
        }
        
        // Pick a proper colour over black and white, unless we're looking at a grayscale image
        guard proposedEdgeColour.0.isNearBlackOrWhite(threshold: blackAndWhiteThreshold) && !isGrayscaleImage else {
            return (proposedEdgeColour.0, imageColours)
        }
        
        for element in countedColours.enumerated() {
            
            guard element.offset + 1 < countedColours.count else { break }
            
            let nextColour = countedColours[element.offset + 1]
            
            // make sure the second choice color is 30% as common as the first choice, or we're on the next colour after the first choice (which was white or black)
            guard element.offset == 0 || Double(nextColour.1) / Double(element.element.1) > Double(subsequentColorRatioThreshold) else {
                break
            }
                
            guard !nextColour.0.isNearBlackOrWhite(threshold: blackAndWhiteThreshold) || isGrayscaleImage else {
                continue
            }
            
            proposedEdgeColour = nextColour
            break
        }
        
        return (proposedEdgeColour.0, imageColours)
    }
    
    private func findTextColours(_ colours: NSCountedSet, backgroundColor: UIColor) -> (primary: UIColor?, secondary: UIColor?, detail: UIColor?)? {
        
        let findDarkTextColor = !backgroundColor.isDark
        let adjustSaturation = options.contains(.increaseTextColourSaturation)
        
        var sortedColors: [(UIColor, Int)] = colours.compactMap { (object) -> (UIColor, Int)? in
            
            guard let color = object as? UIColor else { return nil }
            
            // Make sure color isn't too pale or washed out
            let saturatedColor = adjustSaturation ? color.with(minimumSaturation: 0.15) : color
            guard findDarkTextColor == saturatedColor.isDark else { return nil }
            
            return (saturatedColor, colours.count(for: color))
        }
        
        sortedColors.sort(by: { (pair1, pair2) -> Bool in
            return pair1.1 > pair2.1
        })
        
        guard var currentColour = sortedColors.last?.0 else {
            return nil
        }
        
        var detailColour: UIColor? = nil
        var primaryColour: UIColor? = nil
        var secondaryColour: UIColor? = nil
        
        for element in sortedColors {
            
            currentColour = element.0
            
            if primaryColour == nil {
                
                if currentColour.doesContrastWith(color: backgroundColor) {
                    primaryColour = currentColour
                }
                
            } else if secondaryColour == nil {
                
                guard let _primaryColour = primaryColour,
                    _primaryColour.isDistinctFrom(color: currentColour),
                    currentColour.doesContrastWith(color: backgroundColor) else {
                        continue
                }
                
                secondaryColour = currentColour
                
            } else if detailColour == nil {
                
                guard let _primaryColour = primaryColour,
                    let _secondaryColour = secondaryColour,
                    _secondaryColour.isDistinctFrom(color: currentColour),
                    _primaryColour.isDistinctFrom(color: currentColour),
                    currentColour.doesContrastWith(color: backgroundColor) else {
                        continue
                }
                
                detailColour = currentColour
                break
            }
        }
        
        return (primaryColour, secondaryColour, detailColour)
    }
}

//MARK: - Extensions -

extension UIImage {
    
    /// Looks up a specific pixel in an image and gets it's color
    ///
    /// - Parameter point: The point at which to select a pixel for
    /// - Returns: The color of the selected pixel
    public func pixelColorAt(_ point: CGPoint) -> UIColor? {
        
        guard let cgImage = cgImage else { return nil }
        
        let width = Int(size.width)
        let height = Int(size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create graphics context to render image to
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
            else {
                return nil
        }
        
        // Re-create the image to make sure the image is RGBA rather than it's original colour space
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        guard let pixelBuffer = context.data else { return nil }
        
        let pointer = pixelBuffer.bindMemory(to: UInt32.self, capacity: width * height)
        let pixel = pointer[Int(point.y) * width + Int(point.x)]
        
        // Get pixel RGBA values
        let r: CGFloat = CGFloat(red(for: pixel))   / 255
        let g: CGFloat = CGFloat(green(for: pixel)) / 255
        let b: CGFloat = CGFloat(blue(for: pixel))  / 255
        let a: CGFloat = CGFloat(alpha(for: pixel)) / 255
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    private func alpha(for pixelData: UInt32) -> UInt8 {
        return UInt8((pixelData >> 24) & 255)
    }
    
    private func red(for pixelData: UInt32) -> UInt8 {
        return UInt8((pixelData >> 16) & 255)
    }
    
    private func green(for pixelData: UInt32) -> UInt8 {
        return UInt8((pixelData >> 8) & 255)
    }
    
    private func blue(for pixelData: UInt32) -> UInt8 {
        return UInt8((pixelData >> 0) & 255)
    }
    
    private func rgba(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> UInt32 {
        return (UInt32(alpha) << 24) | (UInt32(red) << 16) | (UInt32(green) << 8) | (UInt32(blue) << 0)
    }
}
