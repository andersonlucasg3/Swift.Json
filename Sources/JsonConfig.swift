//
//  JsonConfig.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 09/03/17.
//
//

import Foundation

/// JsonConvertBlock is the block to convert values from object to json and json to object.
public typealias JsonConvertBlock = ((_ object: AnyObject, _ key: String) -> AnyObject?)

/// JsonConfig class for setting custom conversion fields or data types.
public class JsonConfig {
	internal var fieldManualParsing: [String: JsonConvertBlock] = Dictionary()
	internal var dataTypeManualParsing: [String: JsonConvertBlock] = Dictionary()
    internal var remappingManualParsing: [String: String] = Dictionary()
	internal var pathManualParsing: [String: JsonConvertBlock] = Dictionary()
	
	/// Should the JsonWriter include null values, e.g.: { "client": null }
	public var shouldIncludeNullValueKeys: Bool = true
    
    /// You might whant use this property to automatically convert the json/object's properties names case pattern.
    public var casePatternConverter: CasePatternConverter?
	
    public init(_ patternConverter: CasePatternConverter? = nil) {
		self.casePatternConverter = patternConverter
	}
	
	/// Sets the conversion block for a given field name.
	///
	/// - Parameters:
	///   - field: the field name String
	///   - block: the conversion block
	public func set(forField field: String, withConversionBlock block: @escaping JsonConvertBlock) {
		self.fieldManualParsing[field] = block
	}
	
	/// Sets the conversion block for a given data type name.
	///
	/// - Parameters:
	///   - type: the type name, ex: "Date"
	///   - block: the conversion block
	public func set(forDataType type: String, withConversionBlock block: @escaping JsonConvertBlock) {
		self.dataTypeManualParsing[type] = block
	}
    
    /// Sets the value for a given key to be remapped to the given counterpart key.
    /// These values are used as it is, without conversions or threatments.
    ///
    /// - Parameters:
    ///     - objectKey: the name of the field of the object to be mapped
    ///     - jsonKey: the name of the field in the json to be mapped
    public func set(fromKey key: String, to counterpartKey: String) {
        self.remappingManualParsing[key] = counterpartKey
    }
	
	/// Sets the conversion block for a given path of the json.
	///
	/// - Parameters:
	///   - path: the path string, ex: "user_info.address.street"
	///   - block: the conversion block
	public func set(forPath path: String, withConversionBlock block: @escaping JsonConvertBlock) {
		self.pathManualParsing[path] = block
	}
}
