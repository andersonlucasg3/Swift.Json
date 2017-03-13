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
	
	public class func parse(string: String, withConfig config: JsonParserConfig<T>? = nil) -> T? {
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
	
	fileprivate class func isPrimitiveType(_ typeString: String) -> Bool {
		return typeString == "Int" ||
			typeString == "Int16" ||
			typeString == "Int32" ||
			typeString == "Int64" ||
			typeString == "UInt16" ||
			typeString == "UInt32" ||
			typeString == "UInt64" ||
			typeString == "Float" ||
			typeString == "CGFloat" ||
			typeString == "Double" ||
			typeString == "Bool" ||
			typeString == "NSNumber" ||
			self.isStringType(typeString)
	}
	
	fileprivate class func isStringType(_ typeString: String) -> Bool {
		return typeString == "String" ||
			typeString == "NSString"
	}
	
	fileprivate class func isDateType(_ typeString: String) -> Bool {
		return typeString == "Date" || typeString == "NSDate"
	}
	
	fileprivate class func isToCallManualBlock<T : NSObject>(_ key: String, inConfig config: JsonParserConfig<T>? = nil) -> Bool {
		return config != nil && (config?.fieldManualParsing[key] != nil || config?.dataTypeManualParsing[key] != nil)
	}
	
	fileprivate class func stringValueToDateAutomatic(_ string: String?) -> Date? {
		let formatter = DateFormatter()
		if string != nil {
			return formatter.date(from: string!)
		}
		return nil
	}
	
	fileprivate class func populate(instance: inout AnyObject, withJsonObject jsonObject: [String: AnyObject], withConfig config: JsonParserConfig<T>? = nil) {
		var cls: Mirror? = Mirror(reflecting: instance)
		while cls != nil {
			for child in cls!.children {
				let key = child.label!
				let jsonValue = jsonObject[key]
				
				let propertyType = type(of: child.value)
				var typeInfo = self.parseTypeString("\(propertyType)")
				
				if typeInfo.type == nil {
					typeInfo.type = self.getClassFromProperty(key, fromInstance: instance)
				}
				
				if self.isToCallManualBlock(key, inConfig: config) {
					guard let block = config!.fieldManualParsing[key] else { continue }
					let object = block(jsonValue!, key)
					instance.setValue(object, forKey: key)
				} else if self.isToCallManualBlock(typeInfo.typeName, inConfig: config) {
					guard let block = config!.dataTypeManualParsing[typeInfo.typeName] else { continue }
					let object = block(jsonValue!, key)
					instance.setValue(object, forKey: key)
				} else if (self.isPrimitiveType(typeInfo.typeName) && typeInfo.isArray) {
					if typeInfo.isOptional || jsonValue != nil {
						self.populateArray(forKey: key, intoInstance: &instance, withTypeInfo: typeInfo, withJsonArray: jsonValue as! [AnyObject])
					}
				} else if self.isPrimitiveType(typeInfo.typeName) {
					if typeInfo.isOptional || jsonValue != nil {
						instance.setValue(jsonValue, forKey: key)
					}
				} else if self.isDateType(typeInfo.typeName) {
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
			if self.isPrimitiveType(typeInfo.typeName) {
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
	
	fileprivate class func parseGenericType(_ type: String, enclosing: String) -> String {
		let enclosingLength = enclosing.lengthOfBytes(using: .utf8) + 1
		let typeLength = type.lengthOfBytes(using: .utf8) - enclosingLength - 1
		return NSString(string: type).substring(with: NSRange(location: enclosingLength, length: typeLength))
	}
	
	fileprivate class func parseTypeString(_ type: String) -> TypeInfo {
		var isArray = false
		var isOptional = false
		var classType: AnyClass?
		
		var typeString = type
		if type.contains("Optional") {
			isOptional = true
			typeString = self.parseGenericType(type, enclosing: "Optional")
		}
		
		if typeString.contains("Array") {
			isArray = true
			typeString = self.parseGenericType(typeString, enclosing: "Array")
		}
		
		if self.isPrimitiveType(typeString) {
			classType = NSClassFromString("Swift.\(typeString)")
		} else {
			classType = NSClassFromString(typeString)
		}
		
		return (type: classType, typeName: typeString, isOptional: isOptional, isArray: isArray)
	}
	
	fileprivate class func getClassFromProperty(_ name: String, fromInstance instance: AnyObject) -> AnyClass? {
		let charArray = NSString(string: name).utf8String
		
		let instanceClass: AnyClass? = instance.classForCoder
		guard let property = class_getProperty(instanceClass, charArray) else { return nil }
		guard let attributes = property_getAttributes(property) else { return nil }
		
		let attributeString = String(cString: attributes)
		let slices = attributeString.components(separatedBy: "\"")
		if slices.count > 1 {
			let clsName = slices[1]
			
			return NSClassFromString(clsName)
		}
		return nil
	}
}