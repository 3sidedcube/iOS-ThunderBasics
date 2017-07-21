//
//  DateHelpers.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 20/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public struct DateRange {
	
	public let start: Date
	
	public let end: Date
	
	public func contains(date: Date) -> Bool {
		return date >= start && date <= end
	}
}

public extension Date {
	
	public var daysInWeek: Int? {
		return Calendar.current.maximumRange(of: .weekday)?.count
	}
	
	public var daysInMonth: Int? {
		return Calendar.current.range(of: .day, in: .month, for: self)?.count
	}
	
	public var monthsInYear: Int? {
		return Calendar.current.range(of: .month, in: .year, for: self)?.count
	}
	
	public var isInToday: Bool {
		return Calendar.current.isDateInToday(self)
	}
	
	public var isInYesterday: Bool {
		return Calendar.current.isDateInYesterday(self)
	}
	
	public var isInTomorrow: Bool {
		return Calendar.current.isDateInTomorrow(self)
	}
	
	public var isInWeekend: Bool {
		return Calendar.current.isDateInWeekend(self)
	}
	
	public var isInThisWeek: Bool {
		return Calendar.current.compare(self, to: Date(), toGranularity: .weekOfYear) == .orderedSame && isInThisYear
	}
	
	public var isInThisMonth: Bool {
		return Calendar.current.compare(self, to: Date(), toGranularity: .month) == .orderedSame && isInThisYear
	}
	
	public var isInThisYear: Bool {
		return Calendar.current.compare(self, to: Date(), toGranularity: .year) == .orderedSame
	}
	
	public func dateRange(for dateComponent: Calendar.Component, with options: NSDateRangeOptions = []) -> DateRange? {
		
		let calendar = Calendar.current
		var dateComponents = calendar.dateComponents([.day, .weekday, .month, .weekOfYear, .year], from: self)
		
		if #available(iOS 10.0, *) {
			guard let dateInterval = calendar.dateInterval(of: dateComponent, for: self) else { return nil }
			return DateRange(start: dateInterval.start, end: dateInterval.start.addingTimeInterval(dateInterval.duration))
		}
		
		guard let day = dateComponents.day, let weekday = dateComponents.weekday, let month = dateComponents.month, let year = dateComponents.year else {
			return nil
		}
		
		guard let _daysInWeek = daysInWeek, let _daysInMonth = daysInMonth, let _monthsInYear = monthsInYear else { return nil }
		
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
				endDateComponentsToSubtract?.day = _daysInWeek - weekday
				
			} else {
				
				// Calculate the difference in days between the current day and the beginning of the week
				startDateComponentsToSubtract = DateComponents()
				startDateComponentsToSubtract?.day = -(weekday - calendar.firstWeekday)
			}
			
			// If options doesn't contain includeOriginalDay
			if !options.contains(.includeOriginalDay) {
				
				if options.contains(.directionFuture) {
					
					// As long as we're not already the last day in the week, then set start date to the day after self
					if weekday != _daysInWeek {
						
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
						
						startDateComponentsToSubtract?.day = (startDateComponentsToSubtract?.day ?? 0) - _daysInWeek
					}
				}
			}
			
			break
		case .month:
			
			if options.contains(.directionFuture) {
				
				endComponents.day = daysInMonth
				
				if (options.contains(.includeOriginalDay) && options.contains(.includeOriginalWeek)) || (options.contains(.includeOriginalDay)) { // End date should be the end of self
					
				} else if options.contains(.includeOriginalWeek) {
					
					let daysFromNowUntilEndOfWeek = _daysInWeek - weekday
					// Make sure we don't go beyond the end of the month (This would result in a start date later than bein date)
					if day + daysFromNowUntilEndOfWeek < _daysInMonth {
						
						endDateComponentsToSubtract = DateComponents()
						endDateComponentsToSubtract?.day = _daysInWeek - weekday
					}
				} else {
					
					// Make sure we don't go beyond the end of the month (This would result in a start date later than begin date.)
					if day < _daysInMonth {
						
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
						endComponents.month = _monthsInYear
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
}