//
//  JsonWriter.swift
//  Swift.Json
//
//  Created by Anderson Lucas C. Ramos on 13/03/17.
//
//

import Foundation

/// JsonWriter class for writing json strings from structured objects.
public class JsonWriter {
	fileprivate static let commons: JsonCommon = JsonCommon()
	
	/// Writes a json formatted string from a Swift class object.
	///
	/// - Parameter anyObject: instance of an object to be written.
	/// - Returns: a String of json formatted representation of the anyObject.
	public class func write<T : NSObject>(anyObject: T) -> String? {
		let jsonObject = self.jsonObject(fromObject: anyObject)
		guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions(rawValue: 0)) else { return nil }
		return String(data: data, encoding: .utf8)
	}
	
	fileprivate class func jsonObject<T : NSObject>(fromObject object: T, withConfig config: JsonConfig? = nil) -> [String: AnyObject] {
		var jsonObject = [String: AnyObject]()
		
		var cls: Mirror? = Mirror(reflecting: object)
		while (cls != nil) {
			for child in cls!.children {
				guard let key = child.label else { continue }
				let value: AnyObject? = child.value as AnyObject?
				
				let propertyType = type(of: child.value)
				var typeInfo = self.commons.parseTypeString("\(propertyType)")
				
				if typeInfo.type == nil {
					typeInfo.type = self.commons.getClassFromProperty(key, fromInstance: object)
				}
				
				if self.commons.isToCallManualBlock(key, inConfig: config) {
					guard let block = config!.fieldManualParsing[key] else { continue }
					let jsonValue = block(value as AnyObject, key)
					jsonObject[key] = jsonValue
				} else if self.commons.isToCallManualBlock(typeInfo.typeName, inConfig: config) {
					guard let block = config!.dataTypeManualParsing[typeInfo.typeName] else { continue }
					let jsonValue = block(value as AnyObject, key)
					jsonObject[key] = jsonValue
				} else if self.commons.isPrimitiveType(typeInfo.typeName) && typeInfo.isArray {
					jsonObject[key] = value as AnyObject?
				} else if self.commons.isPrimitiveType(typeInfo.typeName) {
					jsonObject[key] = value as AnyObject?
				} else if self.commons.isDateType(typeInfo.typeName) {
					jsonObject[key] = self.commons.stringValueToDateAutomatic(value as? String) as AnyObject?
				} else {
					if value is NSNull || value == nil {
						jsonObject[key] = NSNull()
					} else if value is NSObject {
						if typeInfo.isArray {
							let jArray = self.jsonArray(fromObjects: value as! [AnyObject], withTypeInfo: typeInfo)
							jsonObject[key] = jArray as AnyObject?
						} else {
							let jObj = self.jsonObject(fromObject: value as! NSObject)
							jsonObject[key] = jObj as AnyObject?
						}
					}
				}
			}
			cls = cls?.superclassMirror
		}
		
		return jsonObject
	}
	
	fileprivate class func jsonArray(fromObjects objects: [AnyObject], withTypeInfo typeInfo: TypeInfo) -> AnyObject {
		if self.commons.isPrimitiveType(typeInfo.typeName) {
			return objects as AnyObject
		}
		
		var jsonArray = [AnyObject]()
		
		for obj in objects {
			let jObj = self.jsonObject(fromObject: obj as! NSObject)
			jsonArray.append(jObj as AnyObject)
		}
		
		return jsonArray as AnyObject
	}
}
