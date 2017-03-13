//
//  JsonParserConfig.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 09/03/17.
//
//

import Foundation

public typealias JsonParserBlock = ((_ object: AnyObject, _ andKey: String) -> AnyObject?)

public class JsonParserConfig<T : NSObject> {
	internal var fieldManualParsing: [String: JsonParserBlock] = Dictionary()
	internal var dataTypeManualParsing: [String: JsonParserBlock] = Dictionary()
	
	public init() {
		
	}
	
	public func set(forField field: String, parserBlock block: @escaping JsonParserBlock) {
		self.fieldManualParsing[field] = block
	}
	
	public func set(forDataType type: String, parserBlock block: @escaping JsonParserBlock) {
		self.dataTypeManualParsing[type] = block
	}
}
