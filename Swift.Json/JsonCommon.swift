//
//  JsonCommon.swift
//  Swift.Json
//
//  Created by Anderson Lucas C. Ramos on 13/03/17.
//
//

import Foundation

internal typealias TypeInfo = (type: AnyClass?, typeName: String, isOptional: Bool, isArray: Bool)

internal typealias PrimitiveValueBlock = ((_ instance: AnyObject, _ value: AnyObject?, _ key: String) -> Void)
internal typealias ManualValueBlock = PrimitiveValueBlock
internal typealias ArrayValueBlock = ((_ instance: AnyObject, _ typeInfo: TypeInfo, _ value: AnyObject?, _ key: String) -> Void)
internal typealias ObjectValueBlock = ((_ instance: AnyObject, _ typeInfo: TypeInfo, _ value: AnyObject?, _ key: String) -> Void)

internal class JsonCommon {
	var primitiveValueBlock: PrimitiveValueBlock?
	var manualValueBlock: ManualValueBlock?
	var arrayValueBlock: ArrayValueBlock?
	var objectValueBlock: ObjectValueBlock?
	
	internal func isToCallManualBlock(_ key: String, inConfig config: JsonConfig? = nil) -> Bool {
		return config != nil && (config?.fieldManualParsing[key] != nil || config?.dataTypeManualParsing[key] != nil)
	}
	
	internal func stringValueToDateAutomatic(_ string: String?) -> Date? {
		let formatter = DateFormatter()
		if string != nil {
			return formatter.date(from: string!)
		}
		return nil
	}
	
	internal func isPrimitiveType(_ typeString: String) -> Bool {
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
	
	internal func isStringType(_ typeString: String) -> Bool {
		return typeString == "String" ||
			typeString == "NSString"
	}
	
	internal func isDateType(_ typeString: String) -> Bool {
		return typeString == "Date" || typeString == "NSDate"
	}
	
	internal func parseGenericType(_ type: String, enclosing: String) -> String {
		let enclosingLength = enclosing.lengthOfBytes(using: .utf8) + 1
		let typeLength = type.lengthOfBytes(using: .utf8) - enclosingLength - 1
		return NSString(string: type).substring(with: NSRange(location: enclosingLength, length: typeLength))
	}
	
	internal func parseTypeString(_ type: String) -> TypeInfo {
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
	
	internal func getClassFromProperty(_ name: String, fromInstance instance: AnyObject) -> AnyClass? {
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
	
	internal func populate(instance: inout AnyObject, withJsonObject jsonObject: [String: AnyObject], withConfig config: JsonConfig? = nil) {
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
//					instance.setValue(object, forKey: key)
					self.manualValueBlock?(instance, object, key)
					
				} else if self.isToCallManualBlock(typeInfo.typeName, inConfig: config) {
					
					guard let block = config!.dataTypeManualParsing[typeInfo.typeName] else { continue }
					let object = block(jsonValue!, key)
//					instance.setValue(object, forKey: key)
					self.manualValueBlock?(instance, object, key)
					
				} else if (self.isPrimitiveType(typeInfo.typeName) && typeInfo.isArray) {
					
					if typeInfo.isOptional || jsonValue != nil {
//						self.populateArray(forKey: key, intoInstance: &instance, withTypeInfo: typeInfo, withJsonArray: jsonValue as! [AnyObject])
						self.arrayValueBlock?(instance, typeInfo, jsonValue, key)
					}
					
				} else if self.isPrimitiveType(typeInfo.typeName) {
					
					if typeInfo.isOptional || jsonValue != nil {
//						instance.setValue(jsonValue, forKey: key)
						self.primitiveValueBlock?(instance, jsonValue, key)
					}
					
//				} else if self.isDateType(typeInfo.typeName) {
//					
//					if typeInfo.isOptional || jsonValue != nil {
//						let date = self.stringValueToDateAutomatic(jsonValue as? String)
////						instance.setValue(date, forKey: key)
//						self.primitiveValueBlock?(instance, jsonValue, key)
//					}
//					
				} else {
					if jsonValue != nil {
						if typeInfo.isArray {
//							self.populateArray(forKey: key, intoInstance: &instance, withTypeInfo: typeInfo, withJsonArray: jsonValue as! [AnyObject])
							self.arrayValueBlock?(instance, typeInfo, jsonValue, key)
						} else {
//							self.populateObject(forKey: key, intoInstance: instance, withTypeInfo: typeInfo, withJsonObject: jsonValue as! [String: AnyObject])
							self.objectValueBlock?(instance, typeInfo, jsonValue, key)
						}
					} else {
//						instance.setValue(nil, forKey: key)
						self.primitiveValueBlock?(instance, nil, key)
					}
				}
			}
			
			cls = cls?.superclassMirror
		}
	}
}
