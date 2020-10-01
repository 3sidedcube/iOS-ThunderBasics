//
//  DateHelpers.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 20/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public struct DateRange {
	
	/// Options available when calculating a date range
	public struct Options: OptionSet {
		
		public let rawValue: Int
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		/// Include the beginning day in the date calculation
		public static let includeOriginalDay = Options(rawValue: 1 << 1)
		/// Include the beginning week in the date calculation
		public static let includeOriginalWeek = Options(rawValue: 1 << 2)
		/// Include the beginning month in the date calculation
		public static let includeOriginalMonth = Options(rawValue: 1 << 3)
		/// Unknown
		public static let directionFuture = Options(rawValue: 1 << 6)
		/// Specifies that the week starts on a Sunday, not a Monday
		public static let weekStartsOnSunday = Options(rawValue: 1 << 7)
	}
	
    /// The beginning of the date range.
	public let start: Date
	
    /// The end of the date range.
	public let end: Date
	
    /// Whether a certain date falls within the date range.
    ///
    /// - Parameter date: The date to check if it falls in the date range.
    /// - Returns: A boolean as to wether the date falls within the range.
	public func contains(date: Date) -> Bool {
		return date >= start && date <= end
	}
    
    /// Creates a date range for a start and end date
    ///
    /// - Parameters:
    ///   - start: The beginning of the date range
    ///   - end: The end of the date range
    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
    
    /// Initialises a date range from the beginning of a given day until the end of a day x days afterwards.
    ///
    /// - Parameters:
    ///   - days: The number of days after the given date the date range should end.
    ///   - date: The date to start the date range at.
    /// - Returns: A date range if one could be created.
    public static func rangeByAdding(days: Int, to date: Date) -> DateRange? {
        
        let calendar = Calendar.current
        let startDate: Date = days > 0 ? date.startOfDay : date
        var endDate: Date? = date
        
        var endComponents = DateComponents()
        
        let units: Set<Calendar.Component> = [
            .year,
            .month,
            .day
        ]
        
        endComponents.day = days
        endComponents = calendar.dateComponents(units, from: calendar.date(byAdding: endComponents, to: date) ?? date)
        endDate = calendar.date(from: endComponents)?.endOfDay
        
        guard let _endDate = endDate else {
            return nil
        }
        
        return DateRange(start: startDate, end: _endDate)
    }
}

public func ==(lhs: DateRange, rhs: DateRange) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

public extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: startOfDay)
        return date?.addingTimeInterval(-1)
    }
	
    var daysInWeek: Int? {
		return Calendar.current.maximumRange(of: .weekday)?.count
	}
	
    var daysInMonth: Int? {
		return Calendar.current.range(of: .day, in: .month, for: self)?.count
	}
	
    var monthsInYear: Int? {
		return Calendar.current.range(of: .month, in: .year, for: self)?.count
	}
	
    var isInToday: Bool {
		return Calendar.current.isDateInToday(self)
	}
	
    var isInYesterday: Bool {
		return Calendar.current.isDateInYesterday(self)
	}
	
    var isInTomorrow: Bool {
		return Calendar.current.isDateInTomorrow(self)
	}
	
    var isInWeekend: Bool {
		return Calendar.current.isDateInWeekend(self)
	}
	
    var isInThisWeek: Bool {
		return Calendar.current.compare(self, to: Date(), toGranularity: .weekOfYear) == .orderedSame && isInThisYear
	}
	
    var isInThisMonth: Bool {
		return Calendar.current.compare(self, to: Date(), toGranularity: .month) == .orderedSame && isInThisYear
	}
	
    var isInThisYear: Bool {
		return Calendar.current.compare(self, to: Date(), toGranularity: .year) == .orderedSame
	}
    
    func dateRange(for dateComponent: Calendar.Component, with options: DateRange.Options = []) -> DateRange? {
		
		let calendar = Calendar.current
		var dateComponents = calendar.dateComponents([.day, .weekday, .month, .weekOfYear, .year], from: self)
		
		if #available(iOS 10.0, *) {
			guard let dateInterval = calendar.dateInterval(of: dateComponent, for: self) else { return nil }
			return DateRange(start: dateInterval.start, end: dateInterval.start.addingTimeInterval(dateInterval.duration))
		}
		
		guard let day = dateComponents.day, let weekday = dateComponents.weekday, let month = dateComponents.month, let year = dateComponents.year else {
			return nil
		}
		
		guard let daysInWeek = daysInWeek, let daysInMonth = daysInMonth, let monthsInYear = monthsInYear else { return nil }
		
		// If week day doesn't start on sunday, move all days back one
		if let weekDay = dateComponents.weekday, !options.contains(.weekStartsOnSunday) {
			
			if dateComponents.weekday == 1 {
				dateComponents.weekday = daysInWeek
			} else {
				dateComponents.weekday = weekDay - 1
			}
		}
		
		var endComponents = dateComponents
		var startComponents = dateComponents
		var startDateComponentsToSubtract: DateComponents?
		var endDateComponentsToSubtract: DateComponents?
		
		var startDate: Date?
		var endDate: Date?
		
		// At the moment we will always set the start date and end date hour and minute to the beginning/end of the day
		startComponents.hour = 0
		startComponents.minute = 0
		endComponents.hour = 23
		endComponents.minute = 59
		
		switch dateComponent {
		case .weekOfYear, .weekOfMonth:
			
			if options.contains(.directionFuture) {
				
				// Calculate the difference in days between the current day and the end of the week
				endDateComponentsToSubtract = DateComponents()
				endDateComponentsToSubtract?.day = daysInWeek - weekday
				
			} else {
				
				// Calculate the difference in days between the current day and the beginning of the week
				startDateComponentsToSubtract = DateComponents()
				startDateComponentsToSubtract?.day = -(weekday - calendar.firstWeekday)
			}
			
			// If options doesn't contain includeOriginalDay
			if !options.contains(.includeOriginalDay) {
				
				if options.contains(.directionFuture) {
					
					// As long as we're not already the last day in the week, then set start date to the day after self
					if weekday != daysInWeek {
						
						startDateComponentsToSubtract = DateComponents()
						startDateComponentsToSubtract?.day = 1
					}
					
				} else {
					
					// If we're asking for the last week without today, and it's also the first day in the week, make sure to also reduce the start date to the start of said week
					endDateComponentsToSubtract = DateComponents()
					endDateComponentsToSubtract?.day = -1
					
					if weekday == 1 {
						
						if startDateComponentsToSubtract == nil {
							startDateComponentsToSubtract = DateComponents()
						}
						
						let currentStartDateComponentsToSubtract = startDateComponentsToSubtract
						startDateComponentsToSubtract?.day = (currentStartDateComponentsToSubtract?.day ?? 0) - daysInWeek
					}
				}
			}
			
			break
		case .month:
			
			if options.contains(.directionFuture) {
				
				endComponents.day = daysInMonth
				
				if (options.contains(.includeOriginalDay) && options.contains(.includeOriginalWeek)) || (options.contains(.includeOriginalDay)) { // End date should be the end of self
					
				} else if options.contains(.includeOriginalWeek) {
					
					let daysFromNowUntilEndOfWeek = daysInWeek - weekday
					// Make sure we don't go beyond the end of the month (This would result in a start date later than bein date)
					if day + daysFromNowUntilEndOfWeek < daysInMonth {
						
						endDateComponentsToSubtract = DateComponents()
						endDateComponentsToSubtract?.day = daysInWeek - weekday
					}
				} else {
					
					// Make sure we don't go beyond the end of the month (This would result in a start date later than begin date.)
					if day < daysInMonth {
						
						startDateComponentsToSubtract = DateComponents()
						startDateComponentsToSubtract?.day = 1
					}
				}
			} else {
				
				startComponents.day = 1
				if (options.contains(.includeOriginalDay) && options.contains(.includeOriginalWeek)) || (options.contains(.includeOriginalDay)) { // End date should be the end of self
					
				} else if options.contains(.includeOriginalWeek) {
					
					if day != 1 {
						endDateComponentsToSubtract = DateComponents()
						endDateComponentsToSubtract?.day = -1
					}
				} else {
					
					endDateComponentsToSubtract = DateComponents()
					endDateComponentsToSubtract?.day = -(weekday - calendar.firstWeekday + 1)
					// If we would be going to the previous month, let's stop ourselves
					if let endDayToSubtract = endDateComponentsToSubtract?.day, endDayToSubtract > day {
						endDateComponentsToSubtract?.day = day - 1
					}
				}
				
			}
		case .year, .yearForWeekOfYear:
			
			if !options.contains(.directionFuture) {
				
				startComponents.day = 1
				startComponents.month = 1
				
				if options.contains(.includeOriginalMonth) || options.contains(.includeOriginalWeek) || options.contains(.includeOriginalDay) {
					
				} else {
					
					if month == 1 {
						startComponents.year = year - 1
						endComponents.month = monthsInYear
						endComponents.year = year - 1
					} else {
						endComponents.month = month - 1
					}
					
					let dateInPreviousMonth = calendar.date(from: endComponents)
					endComponents.day = dateInPreviousMonth?.daysInMonth
				}
			}
			
			break
		default:
			
			break
		}
		
		startDate = calendar.date(from: startComponents)
		endDate = calendar.date(from: endComponents)
		
		if let _startDateComponentsToSubtract = startDateComponentsToSubtract, let _startDate = startDate {
			startDate = calendar.date(byAdding: _startDateComponentsToSubtract, to: _startDate)
		}
		
		if let _endDateComponentsToSubtract = endDateComponentsToSubtract, let _endDate = endDate {
			endDate = calendar.date(byAdding: _endDateComponentsToSubtract, to: _endDate)
		}
		
		guard let _startDate = startDate, let _endDate = endDate else { return nil }
		return DateRange(start: _startDate, end: _endDate)
	}
	
	//MARK: -
	//MARK: ISO8601 Dates
	//MARK: -
	
	/// Initialises and returns a `Date` struct from an ISO8601 string date
	///
	/// - Parameters:
	///   - ISO8601String: The string to convert to a date
	///   - considerLocale: Whether or not to consider the locale when constructing the date
	/// - Returns: A `Date` object if one can be initialised from the string
	init?(ISO8601String: String, considerLocale: Bool = true) {
		
		let dateFormatString = considerLocale ? "yyyy-MM-dd'T'HH:mm:ssZZZ" : "yyyy-MM-dd"
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = dateFormatString
		
		if let date = dateFormatter.date(from: ISO8601String) {
			self = date
		} else {
			
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			guard let date = dateFormatter.date(from: ISO8601String) else { return nil }
			self = date
		}		
	}
	
	/// Returns an ISO8601 formatted string from the Date struct
	///
	/// - Parameter withLocale: Whether to include the locale in the formatted string
	/// - Returns: A string representation of the date
	func ISO8601String(withLocale: Bool) -> String {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = withLocale ? "yyyy-MM-dd'T'HH:mm:ssZ" : "yyyy-MM-dd'T'HH:mm:ss"
		return dateFormatter.string(from: self)
	}
}
