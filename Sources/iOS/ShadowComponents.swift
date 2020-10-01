//
//  ShadowComponents.swift
//  ShadowView
//
//  Created by Simon Mitchell on 23/07/2020.
//  Copyright © 2020 3 Sided Cube. All rights reserved.
//

import UIKit

/// Component representation of all properties required to render a shadow in UIKit
public struct ShadowComponents {
    
    /// The system default shadow
    public static let systemDefault: ShadowComponents = .init(
        radius: 3,
        opacity: 0,
        color: .black,
        offset: .init(width: 0, height: -3)
    )
    
    /// The blur radius of the shadow
    public let radius: CGFloat
    
    /// The opacity of the shadow
    public let opacity: Float
    
    /// The color of the shadow
    public let color: UIColor
    
    /// The offset of the shadow
    public let offset: CGSize
    
    /// Default memberwise initialiser for the components
    /// - Parameters:
    ///   - radius: The blur radius of the shadow
    ///   - opacity: The opacity of the shadow
    ///   - color: The color of the shadow
    ///   - offset: The offset of the shadow
    public init(radius: CGFloat, opacity: Float, color: UIColor, offset: CGSize) {
        self.radius = radius
        self.opacity = opacity
        self.color = color
        self.offset = offset
    }
}
