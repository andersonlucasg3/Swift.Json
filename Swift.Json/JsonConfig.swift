//
//  JsonConfig.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 09/03/17.
//
//

import Foundation

public typealias JsonConvertBlock = ((_ object: AnyObject, _ andKey: String) -> AnyObject?)

public class JsonConfig {
	internal var fieldManualParsing: [String: JsonConvertBlock] = Dictionary()
	internal var dataTypeManualParsing: [String: JsonConvertBlock] = Dictionary()
	
	public init() {
		
	}
	
	public func set(forField field: String, withConversionBlock block: @escaping JsonConvertBlock) {
		self.fieldManualParsing[field] = block
	}
	
	public func set(forDataType type: String, withConversionBlock block: @escaping JsonConvertBlock) {
		self.dataTypeManualParsing[type] = block
	}
}
