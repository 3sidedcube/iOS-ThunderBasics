//
//  SingleRequestLocationManager.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import CoreLocation
import os.log

/// A closure used by SingleRequestLocationManager
public typealias LocationRequestCompletion = (_ location: CLLocation?, _ error: Error?) -> Void

/// A class for performing a single request for the user's current location using CLLocationManager
public final class SingleRequestLocationManager: NSObject {
    
    /// Localisation permissions authorization type
    ///
    /// - whenInUse: When the user is using the app
    /// - always: All the time
    public enum Authorization {
        case whenInUse
        case always
    }
    
    /// Returns the shared instance of the single request location manager.
    /// This solves the problem of having to retain a strong reference to an individual
    /// instance of `SingleRequestLocationManager`
    public static let shared = SingleRequestLocationManager()
    
    fileprivate(set) lazy var locationManager: CLLocationManager = {
        return CLLocationManager()
    }()
    
    fileprivate(set) lazy var log: OSLog = {
        return OSLog(subsystem: "com.threesidedcube.ThunderCloud", category: "SingleRequestLocationManager")
    }()
    
    public override init() {
        super.init()
    }
    
    fileprivate var completionHandlers: [LocationRequestCompletion] = []
    
    /// Requests a users current location and fires a completion block once it has established that an accurate location has been found, or that an error has occured
    ///
    /// - Parameters:
    ///   - authorization: The authorization method for the request. Defines whether the app can use location services in the background or not
    ///   - accuracy: The accuracy of the location request
    ///   - completion: A closure to be called when the manager has found or failed to find the current location
    public func requestCurrentLocation(authorization: Authorization = .whenInUse, accuracy: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters, _ completion: @escaping LocationRequestCompletion) {
        
        locationManager.desiredAccuracy = accuracy
        locationManager.delegate = self
        completionHandlers.append(completion)
        
        switch (CLLocationManager.authorizationStatus(), authorization) {
        case (.denied, _):
            os_log("Location permissions denied, returning", log: log, type: .debug)
            callAllCompletionHandlersWith(location: nil, error: SingleRequestLocationManagerError.permissionsDenied)
        case (.restricted, _):
            os_log("Location permissions restricted, returning", log: log, type: .debug)
            callAllCompletionHandlersWith(location: nil, error: SingleRequestLocationManagerError.permissionsRestricted)
            // If we have the correct permissions, request the location!
        case (.authorizedAlways, .always),
             (.authorizedWhenInUse, .whenInUse),
             (.authorizedAlways, .whenInUse):
            os_log("Location permissions valid, fetching location", log: log, type: .debug)
            if #available(OSX 10.14, *) {
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
            // If we have when in use or not determined, but want always!
        case (.authorizedWhenInUse, .always),
             (.notDetermined, .always):
            os_log("Location permissions don't match, requesting always permissions", log: log, type: .debug)
            #if os(iOS) || os(tvOS) || os(watchOS)
            locationManager.requestAlwaysAuthorization()
            #endif
        case (.notDetermined, .whenInUse):
            os_log("Location permissions don't match, requesting when in use permissions", log: log, type: .debug)
            #if os(iOS) || os(tvOS) || os(watchOS)
            locationManager.requestWhenInUseAuthorization()
            #endif
        case (_, _):
            fatalError("Unknown case hit requesting current location, please add support in `SingleRequestLocationManager.swift`'s `requestCurrentLocation` method")
        }
    }
    
    private func callAllCompletionHandlersWith(location: CLLocation?, error: Error?) {
        completionHandlers.forEach { (completionHandler) in
            completionHandler(location, error)
        }
        cleanUp()
    }
    
    fileprivate func cleanUp() {
        OperationQueue.main.addOperation { [weak self] in
            guard let self = self else { return }
            self.locationManager.delegate = nil
            self.completionHandlers = []
        }
    }
}

public enum SingleRequestLocationManagerError: LocalizedError {
    
    case permissionsDenied
    case permissionsRestricted
    
    public var errorDescription: String? {
        switch self {
        case .permissionsRestricted:
            return "Location permissions are restricted"
        case .permissionsDenied:
            return "Location permissions were denied"
        }
    }
}

extension SingleRequestLocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // Only start up if a user has actually requested location by now
            guard !completionHandlers.isEmpty else {
                os_log("Received change in location permissions", log: log, type: .debug)
                return
            }
            os_log("Received change in location permissions, requesting location", log: log, type: .debug)
            if #available(OSX 10.14, *) {
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            os_log("User denied location permissions", log: log, type: .debug)
            callAllCompletionHandlersWith(
                location: nil,
                error: status == .denied ?
                    SingleRequestLocationManagerError.permissionsDenied :
                    SingleRequestLocationManagerError.permissionsRestricted
            )
        case .notDetermined:
            break
        @unknown default:
            fatalError("Unknown `CLAuthorizationStatus` encountered, please add support in `SingleRequestLocationManager`")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let firstLocation = locations.first else { return }
        
        os_log("New location: %@", log: log, type: .debug, firstLocation)
        callAllCompletionHandlersWith(location: firstLocation, error: nil)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("Location manager errored: %{public}@", log: log, type: .error, error.localizedDescription)
        callAllCompletionHandlersWith(location: nil, error: error)
    }
}
