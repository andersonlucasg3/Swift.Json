//
//  JsonConfig.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 09/03/17.
//
//

import Foundation

public enum ParseRule {
    case camelCase
    case snakeCase
    case hyphenCase
    case pascalCase
    case any
    
    fileprivate func stringIs(_ rule: ParseRule, _ string: String) -> Bool {
        switch rule {
        case .camelCase: return !string.contains("-") && !string.contains("_") && string.first == string.lowercased().first
        case .pascalCase: return !string.contains("-") && !string.contains("_") && string.first == string.uppercased().first
        case .snakeCase: return !string.contains("-") && string == string.lowercased()
        case .hyphenCase: return !string.contains("_") && string == string.lowercased()
        case .any: return true
        }
    }
}

public typealias ParseRules = (jsonRule: ParseRule, objectRule: ParseRule)

public struct ParseOptions {
    let rules: ParseRules
    
    ///default rules configuration: json file is interpreted as if snake_case, and the NSObject is interpreted as camelCase.
    public init(_ rules: ParseRules = (jsonRule: .snakeCase, objectRule: .camelCase)) {
        self.rules = rules
    }
    
    
}


/// JsonConvertBlock is the block to convert values from object to json and json to object.
public typealias JsonConvertBlock = ((_ object: AnyObject, _ andKey: String) -> AnyObject?)

/// JsonConfig class for setting custom conversion fields or data types.
public class JsonConfig {
	internal var fieldManualParsing: [String: JsonConvertBlock] = Dictionary()
	internal var dataTypeManualParsing: [String: JsonConvertBlock] = Dictionary()
	
	/// Should the JsonWriter include null values, e.g.: { "client": null }
	public var shouldIncludeNullValueKeys: Bool = true
	
	public init() {
		
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
}
