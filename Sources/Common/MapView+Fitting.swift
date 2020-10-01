//
//  MapView+Fitting.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 06/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import MapKit

public extension MKMapView {
	
	/// Sets the visible region so the map displays the specified polygons and annotations
	///
	/// Calling this method updates the value in the region property and potentially other properties to reflect the new map region.
	///
	/// - Parameters:
	///   - polygons: The polygons to show
	///   - annotations: The annotations to show
	///   - animated: Whether the region change should be animated or instantaneous
    func showPolygons(_ polygons: [MKPolygon]?, annotations: [MKAnnotation]? = nil, animated: Bool = false) {
		
		var regionRect = MKMapRect.null
				
	#if os(iOS)
		var insets: UIEdgeInsets = UIEdgeInsets()
	#elseif os(OSX) || os(macOS)
		var insets: NSEdgeInsets = NSEdgeInsets()
	#endif
		
		if let annotations = annotations, !annotations.isEmpty {
			
			annotations.forEach({
				
				let annotationPoint = MKMapPoint.init($0.coordinate)
				let pointRect = MKMapRect(origin: annotationPoint, size: MKMapSize(width: 0.1, height: 0.1))
				regionRect = regionRect.union(pointRect)
			})
			
			#if os(iOS)
				insets = UIEdgeInsets(top: 38, left: 10, bottom: 10, right: 10)
			#elseif os(OSX) || os(macOS)
				insets = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
			#endif
		}
		
		if let polygons = polygons, !polygons.isEmpty {
			
			if regionRect.isNull {
				regionRect = polygons[0].boundingMapRect
			}
			
			polygons.forEach({
				regionRect = regionRect.union($0.boundingMapRect)
			})
		}
		
		guard !regionRect.isNull else { return }
		
		setVisibleMapRect(regionRect, edgePadding: insets, animated: animated)
	}
}
