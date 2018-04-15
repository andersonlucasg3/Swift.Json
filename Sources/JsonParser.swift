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
    
    // MARK: -- Begin Object Parsers
	
	/// Parses a string to the expected generic type populating an object instance mapped to the json string.
	///
	/// - Parameters:
	///   - string: the json string
	///   - config: optional parameter with custom parsing configs
	/// - Returns: The object populated with the values from the json string.
	public func parse<T: NSObject>(string: String, withConfig config: JsonConfig? = nil) -> T? {
		guard let data = string.data(using: .utf8) else { return nil }
		var instance: T = (getInstance() as T)
        self.parse(data: data, into: &instance, withConfig: config)
        return instance
	}
    
    /// Parses a Data to the expected generic type populating an object instance mapped to the json Data.
    ///
    /// - Parameters:
    ///   - data: the json Data
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The object populated with the values from the json Data.
    public func parse<T : NSObject>(data: Data, withConfig config: JsonConfig? = nil) -> T? {
        var instance: T = (getInstance() as T)
        self.parse(data: data, into: &instance, withConfig: config)
        return instance
    }
    
    /// Parses a string to the expected generic type populating an object instance mapped to the json string.
    ///
    /// - Parameters:
    ///   - string: the json string
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The object populated with the values from the json string.
    public func parse<T: NSObject>(string: String, into object: inout T, withConfig config: JsonConfig? = nil) {
        guard let data = string.data(using: .utf8) else { return }
        self.parse(data: data, into: &object, withConfig: config)
    }
    
    /// Parses a Data to the expected generic type populating an object instance mapped to the json Data.
    ///
    /// - Parameters:
    ///   - data: the json Data
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The object populated with the values from the json Data.
    public func parse<T: NSObject>(data: Data, into object: inout T, withConfig config: JsonConfig? = nil) {
        guard let jsonObject = self.getJsonDict(data) else { return }
        self.setupCommons(withConfig: config)
        self.commons.populate(instance: object, withObject: jsonObject as AnyObject, withConfig: config)
        self.unsetupCommons()
    }
    
    // MARK: -- End Object Parsers
    
    // MARK: -- Begin Array parsers
    
    /// Parses a Data to the expected generic type populating an array instance mapped to the json Data.
    ///
    /// - Parameters:
    ///   - data: the json Data
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The array populated with the objects from the json Data.
    public func parse<T: Any>(data: Data, withConfig config: JsonConfig? = nil) -> [T]? {
        guard !self.commons.isPrimitiveType("\(T.self)") else {
            return self.getJsonArray(data)
        }
        guard let jsonArray: [[String: AnyObject]] = self.getJsonArray(data) else { return nil }
        self.setupCommons(withConfig: config)
        let mapped: [T] = jsonArray.map({
            let instance: T = (T.self as! NSObject.Type).init() as! T // (getInstance() as! T)
            self.commons.populate(instance: instance as AnyObject, withObject: $0 as AnyObject, withConfig: config)
            return instance
        })
        self.unsetupCommons()
        return mapped
    }
    
    /// Parses a String to the expected generic type populating an array instance mapped to the json String.
    ///
    /// - Parameters:
    ///   - string: the json String
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The array populated with the objects from the json String.
    public func parse<T: Any>(string: String, withConfig config: JsonConfig? = nil) -> [T]? {
        guard let data = string.data(using: .utf8) else { return nil }
        return self.parse(data: data, withConfig: config)
    }
    
    /// Parses a Data to the expected generic type populating an array instance mapped to the json Data.
    ///
    /// - Parameters:
    ///   - data: the json Data
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The array populated with the objects from the json Data.
    public func parse<T: Any>(data: Data, into array: inout [T], withConfig config: JsonConfig? = nil) {
        guard let arrayObjs: [T] = self.parse(data: data, withConfig: config) else { return }
        array.append(contentsOf: arrayObjs)
    }
    
    /// Parses a String to the expected generic type populating an array instance mapped to the json String.
    ///
    /// - Parameters:
    ///   - string: the json String
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The array populated with the objects from the json String.
    public func parse<T: Any>(string: String, into array: inout [T], withConfig config: JsonConfig? = nil) {
        guard let data = string.data(using: .utf8) else { return }
        self.parse(data: data, into: &array, withConfig: config)
    }
   
    // MARK: -- End Object Parsers
    
    fileprivate func getJsonDict(_ data: Data) -> [String: AnyObject]? {
        let options = JSONSerialization.ReadingOptions(rawValue: 0)
        var jsonObject: [String: AnyObject]?
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject]
        } catch let error as NSError {
            print("JsonParser error: \(error)")
            return nil
        } catch {
            print("JsonParser error: something went wrong with the json parsing, check the json contents")
            return nil
        }
        return jsonObject
    }
    
    fileprivate func getJsonArray<T: Any>(_ data: Data) -> [T]? {
        let options = JSONSerialization.ReadingOptions(rawValue: 0)
        var jsonArray: [T]?
        do {
            jsonArray = try JSONSerialization.jsonObject(with: data, options: options) as? [T]
        } catch let error as NSError {
            print("JsonParser error: \(error)")
            return nil
        } catch {
            print("JsonParser error: something went wrong with the json parsing, check the json contents")
            return nil
        }
        return jsonArray
    }

    fileprivate func convertCasePatter(_ config: JsonConfig?, for key: String) -> String {
        return config?.casePatternConverter?.convert(key) ?? key
    }
	
    fileprivate func setupCommons(withConfig config: JsonConfig?) {
        //returns the value of instance's attribute(named key) contained in json dictionary (value)
		self.commons.valueBlock = { [unowned self] (instance, value, key) -> AnyObject? in
			guard let dict = value as? [String: AnyObject] else { return nil }
			return dict[self.convertCasePatter(config, for: key)] as AnyObject
		}
		
        //set the value returned by valueBlock in the correct attribute (named key) of instance
		self.commons.primitiveValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
        //unnecessary method (could be replaced by primitiveValueBlock)
		self.commons.manualValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
		self.commons.objectValueBlock = { [unowned self] (instance, typeInfo, value, key) -> Void in
			self.populateObject(forKey: key,
                                 intoInstance: instance,
                                 withTypeInfo: typeInfo,
                                 withObject: value as AnyObject,
                                 withConfig: config)
		}
		
		self.commons.arrayValueBlock = { [unowned self] (instance, typeInfo, value, key) -> Void in
			self.populateArray(forKey: key,
                                intoInstance: instance,
                                withTypeInfo: typeInfo,
                                withJsonArray: value as! [AnyObject],
                                withConfig: config)
		}
	}
	
	fileprivate func unsetupCommons() {
		self.commons.primitiveValueBlock = nil
		self.commons.manualValueBlock = nil
		self.commons.objectValueBlock = nil
		self.commons.arrayValueBlock = nil
	}
	
	fileprivate func getInstance<T: NSObject>() -> T {
		return T()
	}
	
	fileprivate func getInstance(forType type: NSObject.Type) -> AnyObject {
		return type.init()
	}
	
    fileprivate func populateArray(forKey key: String, intoInstance instance: AnyObject, withTypeInfo typeInfo: TypeInfo, withJsonArray jsonArray: [AnyObject], withConfig config: JsonConfig?) {
		var array = [AnyObject]()
		for item in jsonArray {
			if self.commons.isPrimitiveType(typeInfo.typeName) {
				array.append(item)
			} else {
				let cls: AnyClass? = NSClassFromString(typeInfo.typeName)
				assert(cls != nil, "Could not convert class name \(typeInfo.typeName) to AnyClass instance. Please add @objc(\(typeInfo.typeName)) to your class definition.")
				let inst: AnyObject = self.getInstance(forType: cls as! NSObject.Type)
				self.commons.populate(instance: inst, withObject: item, withConfig: config)
				array.append(inst)
			}
		}
		instance.setValue(array, forKey: key)
	}
	
    fileprivate func populateObject(forKey key: String, intoInstance instance: AnyObject, withTypeInfo typeInfo: TypeInfo, withObject object: AnyObject, withConfig config: JsonConfig?) {
		let propertyInstance = self.getInstance(forType: typeInfo.type as! NSObject.Type)
		self.commons.populate(instance: propertyInstance, withObject: object, withConfig: config)
		instance.setValue(propertyInstance, forKey: key)
	}
}
