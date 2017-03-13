//
//  JsonCommon.swift
//  Swift.Json
//
//  Created by Anderson Lucas C. Ramos on 13/03/17.
//
//

import Foundation

internal class JsonCommon {
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
}
