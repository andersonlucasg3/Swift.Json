//
//  JsonCommon.swift
//  Swift.Json
//
//  Created by Anderson Lucas C. Ramos on 13/03/17.
//
//

import Foundation

internal typealias TypeInfo = (type: AnyClass?, typeName: String, isOptional: Bool, isArray: Bool)

internal class JsonCommon {
	internal class func isToCallManualBlock(_ key: String, inConfig config: JsonConfig? = nil) -> Bool {
		return config != nil && (config?.fieldManualParsing[key] != nil || config?.dataTypeManualParsing[key] != nil)
	}
	
	internal class func stringValueToDateAutomatic(_ string: String?) -> Date? {
		let formatter = DateFormatter()
		if string != nil {
			return formatter.date(from: string!)
		}
		return nil
	}
	
	internal class func isPrimitiveType(_ typeString: String) -> Bool {
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
	
	internal class func isStringType(_ typeString: String) -> Bool {
		return typeString == "String" ||
			typeString == "NSString"
	}
	
	internal class func isDateType(_ typeString: String) -> Bool {
		return typeString == "Date" || typeString == "NSDate"
	}
	
	internal class func parseGenericType(_ type: String, enclosing: String) -> String {
		let enclosingLength = enclosing.lengthOfBytes(using: .utf8) + 1
		let typeLength = type.lengthOfBytes(using: .utf8) - enclosingLength - 1
		return NSString(string: type).substring(with: NSRange(location: enclosingLength, length: typeLength))
	}
	
	internal class func parseTypeString(_ type: String) -> TypeInfo {
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
		
		if JsonCommon.isPrimitiveType(typeString) {
			classType = NSClassFromString("Swift.\(typeString)")
		} else {
			classType = NSClassFromString(typeString)
		}
		
		return (type: classType, typeName: typeString, isOptional: isOptional, isArray: isArray)
	}
	
	internal class func getClassFromProperty(_ name: String, fromInstance instance: AnyObject) -> AnyClass? {
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
