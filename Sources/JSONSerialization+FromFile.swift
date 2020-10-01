//
//  JSONSerialization+FromFile.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 06/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension JSONSerialization {
	
	/// Returns a Foundation object from given resource information.
	///
	/// The resource information provided must be to a valid bundled file in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
	///
	/// - Parameters:
	///   - resource: The name of the resource in the provided bundle.
	///   - fileExtension: The file extension of the resource.
	///   - bundle: The bundle to look in for the resource.
	///   - options: Options for reading the JSON data and creating the Foundation objects.
	///              For possible values, see JSONSerialization.ReadingOptions.
	/// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
	/// - Throws: An error if the resource couldn't be found or if JSON serialisation failed.
	open class func jsonObject(with resource: String?, extension fileExtension: String?, in bundle: Bundle = .main, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
		
		guard let path = bundle.url(forResource: resource, withExtension: fileExtension) else {
			throw JSONSerializationError.fileNotFoundInBundle
		}
		
		do {
			let object = try JSONSerialization.jsonObject(with: path, options: opt)
			return object
		} catch let error {
			throw error
		}
	}
	
	/// Returns a Foundation object using data from a given URL.
	///
	/// The file at the URL provided must be to a valid file in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
	///
	/// - Parameters:
	///   - file: The URL to read JSON data from
	///   - options: Options for reading the JSON data and creating the Foundation objects.
	///              For possible values, see JSONSerialization.ReadingOptions.
	/// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
	/// - Throws: An error if the file couldn't be read as Data or if JSON serialisation failed.
	open class func jsonObject(with file: URL, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
		
		do {
			let data = try Data(contentsOf: file)
			let object = try JSONSerialization.jsonObject(with: data, options: opt)
			return object
		} catch let error {
			throw error
		}
	}
}

/// Errors for JSON Serialization extension
///
/// - noFileFoundInBundle: No file was found for the specified resource in the bundle
enum JSONSerializationError: Error {
	case fileNotFoundInBundle
}
