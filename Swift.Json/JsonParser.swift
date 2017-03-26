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
	
	/// Parses a string to the expected generic type populating an object instance mapped to the json string.
	///
	/// - Parameters:
	///   - string: the json string
	///   - config: optional parameter with custom parsing configs
	/// - Returns: The object populated with the values from the json string.
	public class func parse<T: NSObject>(string: String, withConfig config: JsonConfig? = nil) -> T? {
		let options = JSONSerialization.ReadingOptions(rawValue: 0)
		guard let data = string.data(using: .utf8) else { return nil }
		guard let jsonObject = try! JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject] else { return nil }
		
		var instance: AnyObject = (getInstance() as T) as AnyObject
		self.populate(instance: &instance, withJsonObject: jsonObject, withConfig: config)
		return instance as? T
	}
	
	fileprivate class func getInstance<T : NSObject>() -> T {
		return T()
	}
	
	fileprivate class func getInstance(forType type: NSObject.Type) -> AnyObject {
		return type.init()
	}
	
	fileprivate class func populateArray(forKey key: String, intoInstance instance: inout AnyObject, withTypeInfo typeInfo: TypeInfo, withJsonArray jsonArray: [AnyObject]) {
		var array = [AnyObject]()
		for item in jsonArray {
			if JsonCommon.isPrimitiveType(typeInfo.typeName) {
				array.append(item)
			} else {
				var inst: AnyObject = self.getInstance(forType: NSClassFromString(typeInfo.typeName) as! NSObject.Type)
				self.populate(instance: &inst, withJsonObject: item as! [String : AnyObject])
				array.append(inst)
			}
		}
		instance.setValue(array, forKey: key)
	}
	
	fileprivate class func populateObject(forKey key: String, intoInstance instance: AnyObject, withTypeInfo typeInfo: TypeInfo, withJsonObject jsonObject: [String: AnyObject]) {
		var propertyInstance = self.getInstance(forType: typeInfo.type as! NSObject.Type)
		self.populate(instance: &propertyInstance, withJsonObject: jsonObject)
		instance.setValue(propertyInstance, forKey: key)
	}
}
