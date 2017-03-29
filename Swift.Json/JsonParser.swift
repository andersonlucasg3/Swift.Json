//
//  JSONParser.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 08/03/17.
//
//

import Foundation

/// JsonParser class for parsing json strings into structured objects. 
public class JsonParser {
	fileprivate let commons: JsonCommon = JsonCommon()
	
	public init() {
		
	}
	
	/// Parses a string to the expected generic type populating an object instance mapped to the json string.
	///
	/// - Parameters:
	///   - string: the json string
	///   - config: optional parameter with custom parsing configs
	/// - Returns: The object populated with the values from the json string.
	public func parse<T: NSObject>(string: String, withConfig config: JsonConfig? = nil) -> T? {
		let options = JSONSerialization.ReadingOptions(rawValue: 0)
		guard let data = string.data(using: .utf8) else { return nil }
		guard let jsonObject = try! JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject] else { return nil }
	
		self.setupCommons()
		
		let instance: AnyObject = (getInstance() as T) as AnyObject
		self.commons.populate(instance: instance, withObject: jsonObject as AnyObject, withConfig: config)
		
		self.unsetupCommons()
		
		return instance as? T
	}
	
	fileprivate func setupCommons() {
		self.commons.valueBlock = { (instance, value, key) -> AnyObject? in
			guard let dict = value as? [String: AnyObject] else { return nil }
			return dict[key] as AnyObject
		}
		
		self.commons.primitiveValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
		self.commons.manualValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
		self.commons.objectValueBlock = { [weak self] (instance, typeInfo, value, key) -> Void in
			self?.populateObject(forKey: key, intoInstance: instance, withTypeInfo: typeInfo, withObject: value as AnyObject)
		}
		
		self.commons.arrayValueBlock = { [weak self] (instance, typeInfo, value, key) -> Void in
			self?.populateArray(forKey: key, intoInstance: instance, withTypeInfo: typeInfo, withJsonArray: value as! [AnyObject])
		}
	}
	
	fileprivate func unsetupCommons() {
		commons.primitiveValueBlock = nil
		commons.manualValueBlock = nil
		commons.objectValueBlock = nil
		commons.arrayValueBlock = nil
	}
	
	fileprivate func getInstance<T : NSObject>() -> T {
		return T()
	}
	
	fileprivate func getInstance(forType type: NSObject.Type) -> AnyObject {
		return type.init()
	}
	
	fileprivate func populateArray(forKey key: String, intoInstance instance: AnyObject, withTypeInfo typeInfo: TypeInfo, withJsonArray jsonArray: [AnyObject]) {
		var array = [AnyObject]()
		for item in jsonArray {
			if commons.isPrimitiveType(typeInfo.typeName) {
				array.append(item)
			} else {
				let inst: AnyObject = self.getInstance(forType: NSClassFromString(typeInfo.typeName) as! NSObject.Type)
				commons.populate(instance: inst, withObject: item)
				array.append(inst)
			}
		}
		instance.setValue(array, forKey: key)
	}
	
	fileprivate func populateObject(forKey key: String, intoInstance instance: AnyObject, withTypeInfo typeInfo: TypeInfo, withObject object: AnyObject) {
		let propertyInstance = self.getInstance(forType: typeInfo.type as! NSObject.Type)
		commons.populate(instance: propertyInstance, withObject: object)
		instance.setValue(propertyInstance, forKey: key)
	}
}
