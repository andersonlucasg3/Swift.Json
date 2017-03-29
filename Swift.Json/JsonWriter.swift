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
	fileprivate let commons: JsonCommon = JsonCommon()
	
	public init() {
		
	}
	
	/// Writes a json formatted string from a Swift class object.
	///
	/// - Parameter anyObject: instance of an object to be written.
	/// - Returns: a String of json formatted representation of the anyObject.
	public func write<T : NSObject>(anyObject: T) -> String? {
		self.setupCommons()
		
		let jsonObject = self.commons.write(fromObject: anyObject)
		
		self.unsetupCommons()
		
		guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions(rawValue: 0)) else { return nil }
		return String(data: data, encoding: .utf8)
	}
	
	fileprivate func setupCommons() {
		self.commons.valueBlock = { (instance: AnyObject, value, key) -> AnyObject? in
			return (instance as! NSObject).value(forKey: key) as AnyObject
		}
		
		self.commons.primitiveValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
		self.commons.manualValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
		self.commons.objectValueBlock = { [weak self] (instance, typeInfo, value, key) -> Void in
			let jsonObject = self?.commons.write(fromObject: value!)
			instance.setValue(jsonObject, forKey: key)
		}
		
		self.commons.arrayValueBlock = { [weak self] (instance, typeInfo, value, key) -> Void in
			let jsonArray = self?.jsonArray(fromObjects: value as! [AnyObject], withTypeInfo: typeInfo)
			instance.setValue(jsonArray, forKey: key)
		}
	}
	
	fileprivate func unsetupCommons() {
		commons.primitiveValueBlock = nil
		commons.manualValueBlock = nil
		commons.objectValueBlock = nil
		commons.arrayValueBlock = nil
	}
	
	fileprivate func jsonArray(fromObjects objects: [AnyObject], withTypeInfo typeInfo: TypeInfo) -> AnyObject {
		if self.commons.isPrimitiveType(typeInfo.typeName) {
			return objects as AnyObject
		}
		
		var jsonArray = [AnyObject]()
		
		for obj in objects {
			let jObj = self.commons.write(fromObject: obj as! NSObject)
			jsonArray.append(jObj as AnyObject)
		}
		
		return jsonArray as AnyObject
	}
}
