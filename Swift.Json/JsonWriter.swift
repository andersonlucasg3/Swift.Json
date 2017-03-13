//
//  JsonWriter.swift
//  Swift.Json
//
//  Created by Anderson Lucas C. Ramos on 13/03/17.
//
//

import Foundation

class JsonWriter {
	public class func write<T : NSObject>(anyObject: T) -> String? {
		let jsonObject = self.jsonObject(fromObject: anyObject)
		guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted) else { return nil }
		return String(data: data, encoding: .utf8)
	}
	
	fileprivate class func jsonObject<T : NSObject>(fromObject object: T, withConfig config: JsonConfig<T>? = nil) -> [String: AnyObject] {
		var jsonObject = [String: AnyObject]()
		
		var cls: Mirror? = Mirror(reflecting: object)
		while (cls != nil) {
			for child in cls!.children {
				let key = child.label!
				let value = child.value
				
				let propertyType = type(of: value)
				var typeInfo = JsonCommon.parseTypeString("\(propertyType)")
				
				if typeInfo.type == nil {
					typeInfo.type = JsonCommon.getClassFromProperty(key, fromInstance: object)
				}
				
				if JsonCommon.isToCallManualBlock(key, inConfig: config) {
					guard let block = config!.fieldManualParsing[key] else { continue }
					let jsonValue = block(value as AnyObject, key)
					jsonObject[key] = jsonValue
				} else if JsonCommon.isToCallManualBlock(typeInfo.typeName, inConfig: config) {
					guard let block = config!.dataTypeManualParsing[typeInfo.typeName] else { continue }
					let jsonValue = block(value as AnyObject, key)
					jsonObject[key] = jsonValue
				} else if JsonCommon.isPrimitiveType(typeInfo.typeName) && typeInfo.isArray {
					jsonObject[key] = value as AnyObject?
				} else if JsonCommon.isPrimitiveType(typeInfo.typeName) {
					jsonObject[key] = value as AnyObject?
				} else if JsonCommon.isDateType(typeInfo.typeName) {
					jsonObject[key] = JsonCommon.stringValueToDateAutomatic(value as? String) as AnyObject?
				} else {
					let jObj = self.jsonObject(fromObject: value as! NSObject)
					jsonObject[key] = jObj as AnyObject?
				}
			}
			cls = cls?.superclassMirror
		}
		
		return jsonObject
	}
}
