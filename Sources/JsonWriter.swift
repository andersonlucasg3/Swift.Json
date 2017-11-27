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
    
    // MARK: -- Begin Object Writer
	
	/// Writes a json formatted string from a Swift class object.
	///
	/// - Parameters:
	///   - anyObject: instance of an object to be written.
	///   - config: optional parameter with custom writing configs
	/// - Returns: a String of json formatted representation of the anyObject.
	public func write<T: NSObject>(anyObject: T, withConfig config: JsonConfig? = nil) -> String? {
        guard let data: Data = self.write(anyObject: anyObject, withConfig: config) else { return nil }
		return String(data: data, encoding: .utf8)
	}
    
    /// Writes a json formatted data from a Swift class object.
    ///
    /// - Parameters:
    ///   - anyObject: instance of an object to be written.
    ///   - config: optional parameter with custom writing configs
    /// - Returns: a Data of json formatted representation of the anyObject.
    public func write<T: NSObject>(anyObject: T, withConfig config: JsonConfig? = nil) -> Data? {
        self.setupCommons(withConfig: config)
        let jsonObject = self.commons.write(fromObject: anyObject, withConfig: config)
        self.unsetupCommons()
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
    
    // MARK: -- End Object Writer
    
    // MARK: -- Begin Array Writer
    
    /// Writes a json formatted String from a Swift array.
    ///
    /// - Parameters:
    ///   - anyArray: instance of an array to be written.
    ///   - config: optional parameter with custom writing configs
    /// - Returns: a String of json formatted representation of the anyArray.
    public func write<T: AnyObject>(anyArray: [T], withConfig config: JsonConfig? = nil) -> String? {
        guard let data: Data = self.write(anyArray: anyArray, withConfig: config) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Writes a json formatted Data from a Swift array.
    ///
    /// - Parameters:
    ///   - anyArray: instance of an array to be written.
    ///   - config: optional parameter with custom writing configs
    /// - Returns: a Data of json formatted representation of the anyArray.
    public func write<T: AnyObject>(anyArray: [T], withConfig config: JsonConfig? = nil) -> Data? {
        guard !self.commons.isPrimitiveType("\(T.self)") else {
            return try? JSONSerialization.data(withJSONObject: anyArray, options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        self.setupCommons(withConfig: config)
        var jsonArray = [[String: AnyObject]]()
        anyArray.forEach({ anyObject in
            jsonArray.append(self.commons.write(fromObject: anyObject, withConfig: config))
        })
        self.unsetupCommons()
        return try? JSONSerialization.data(withJSONObject: jsonArray, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
    
    // MARK: -- End Array Writer
	
	fileprivate func setupCommons(withConfig config: JsonConfig? = nil) {
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
			let jsonObject = self?.commons.write(fromObject: value!, withConfig: config)
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
	
	fileprivate func jsonArray(fromObjects objects: [AnyObject], withTypeInfo typeInfo: TypeInfo, withConfig config: JsonConfig? = nil) -> AnyObject {
		if self.commons.isPrimitiveType(typeInfo.typeName) {
			return objects as AnyObject
		}
		
		var jsonArray = [AnyObject]()
		
		for obj in objects {
			let jObj = self.commons.write(fromObject: obj as! NSObject, withConfig: config)
			jsonArray.append(jObj as AnyObject)
		}
		
		return jsonArray as AnyObject
	}
}
