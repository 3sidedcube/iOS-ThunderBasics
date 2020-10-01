//
//  NSDateFormatter+Strft.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 06/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    /// Returns a string from a Date object using a strfttime format string
    ///
    /// - Parameters:
    ///   - date: The date to return the string representation for
    ///   - strfttimeFormat: The strftime format to return the string in
    ///   - bufferSize: The buffer is used to create a char array for the string returned from the strftime method (Defaults to 256)
    /// - Returns: The formatted string
    public class func string(from date: Date, strfttimeFormat: String, bufferSize: Int = 256) -> String? {
        
        var t_time = time_t(date.timeIntervalSince1970)
        var timeStruct = tm()
        localtime_r(&t_time, &timeStruct)
        var buffer = [Int8](repeating: 0, count: bufferSize)
        
        strftime(&buffer, bufferSize, strfttimeFormat, &timeStruct)
        
        return String(cString: buffer)
    }
}
