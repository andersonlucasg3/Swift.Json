//
//  JSONParser.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 08/03/17.
//
//

import Foundation

internal typealias TypeInfo = (type: AnyClass?, typeName: String, isOptional: Bool, isArray: Bool)

public class JsonParser<T : NSObject> {
	public init() {
		
	}
	
	public class func parse(string: String, withConfig config: JsonConfig<T>? = nil) -> T? {
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
	
	fileprivate class func isToCallManualBlock<T : NSObject>(_ key: String, inConfig config: JsonConfig<T>? = nil) -> Bool {
		return config != nil && (config?.fieldManualParsing[key] != nil || config?.dataTypeManualParsing[key] != nil)
	}
	
	fileprivate class func stringValueToDateAutomatic(_ string: String?) -> Date? {
		let formatter = DateFormatter()
		if string != nil {
			return formatter.date(from: string!)
		}
		return nil
	}
	
	fileprivate class func populate(instance: inout AnyObject, withJsonObject jsonObject: [String: AnyObject], withConfig config: JsonConfig<T>? = nil) {
		var cls: Mirror? = Mirror(reflecting: instance)
		while cls != nil {
			for child in cls!.children {
				let key = child.label!
				let jsonValue = jsonObject[key]
				
				let propertyType = type(of: child.value)
				var typeInfo = JsonCommon.parseTypeString("\(propertyType)")
				
				if typeInfo.type == nil {
					typeInfo.type = JsonCommon.getClassFromProperty(key, fromInstance: instance)
				}
				
				if self.isToCallManualBlock(key, inConfig: config) {
					guard let block = config!.fieldManualParsing[key] else { continue }
					let object = block(jsonValue!, key)
					instance.setValue(object, forKey: key)
				} else if self.isToCallManualBlock(typeInfo.typeName, inConfig: config) {
					guard let block = config!.dataTypeManualParsing[typeInfo.typeName] else { continue }
					let object = block(jsonValue!, key)
					instance.setValue(object, forKey: key)
				} else if (JsonCommon.isPrimitiveType(typeInfo.typeName) && typeInfo.isArray) {
					if typeInfo.isOptional || jsonValue != nil {
						self.populateArray(forKey: key, intoInstance: &instance, withTypeInfo: typeInfo, withJsonArray: jsonValue as! [AnyObject])
					}
				} else if JsonCommon.isPrimitiveType(typeInfo.typeName) {
					if typeInfo.isOptional || jsonValue != nil {
						instance.setValue(jsonValue, forKey: key)
					}
				} else if JsonCommon.isDateType(typeInfo.typeName) {
					if typeInfo.isOptional || jsonValue != nil {
						let date = self.stringValueToDateAutomatic(jsonValue as? String)
						instance.setValue(date, forKey: key)
					}
				} else {
					if typeInfo.isArray {
						self.populateArray(forKey: key, intoInstance: &instance, withTypeInfo: typeInfo, withJsonArray: jsonValue as! [AnyObject])
					} else {
						self.populateObject(forKey: key, intoInstance: instance, withTypeInfo: typeInfo, withJsonObject: jsonValue as! [String: AnyObject])
					}
				}
			}
			
			cls = cls?.superclassMirror
		}
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
