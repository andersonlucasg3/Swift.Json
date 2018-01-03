//
//  SwiftJsonTests.swift
//  Swift.JsonTests
//
//  Created by Anderson Lucas C. Ramos on 13/03/17.
//
//

import XCTest
@testable import SwiftJson

class Swift_JsonTests: XCTestCase {
    
	#if Xcode
	func testJsonParser() {
		let jsonString = try! String(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "jsonObject", ofType: "json")!)
		
		let config = JsonConfig()
		config.set(forDataType: "Date") { (value, key) -> AnyObject? in
			if key == "date" {
				let formatter = DateFormatter()
				formatter.dateFormat = "dd/MM/yyyy"
				return formatter.date(from: value as! String) as AnyObject
			}
			return nil
		}
		
		let parser = JsonParser()
		let testObject: TestObject? = parser.parse(string: jsonString, withConfig: config)
		assert(testObject != nil)
		assert(testObject?.name == "Anderson")
		assert(testObject?.age == 25)
		assert(testObject?.height == 1.85)
		assert(testObject?.employee?.name == "Jorge Xavier")
		assert(testObject?.employee?.age == 20)
		assert(testObject?.boss?.name == "Thiago N.")
		assert(testObject?.boss?.age == 55)
		assert(testObject?.boss?.bad == true)
		assert(testObject!.employees!.count > 0)
		assert(testObject!.employees![0].name == "Jorge Xavier")
	}
	#endif
	
	func testJsonWriter() {
		let testObject = TestObject()
		testObject.name = "Anderson"
		testObject.age = 27
		testObject.employee = Employee()
		testObject.employee?.name = "Lucas"
		testObject.employee?.age = 35
		
		let writer = JsonWriter()
        let jsonString: String? = writer.write(anyObject: testObject)
		
		let jsonObject = try! JSONSerialization.jsonObject(with: jsonString!.data(using: .utf8)!, options: .allowFragments) as! [String: AnyObject]
		
		assert(testObject.name == jsonObject["name"] as? String)
		assert(testObject.age == jsonObject["age"] as? Int)
		
		let employee = jsonObject["employee"] as! [String: AnyObject]
		assert(testObject.employee?.name == employee["name"] as? String)
		assert(testObject.employee?.age == employee["age"] as? Int)
	}
	
	func testArrayWriting() {
		let emp1 = Employee()
		emp1.name = "Emp 1"
		emp1.age = 55
		let emp2 = Employee()
		emp2.name = "Emp 2"
		emp2.age = 35
		
		let testObject = TestObject()
		testObject.name = "Anderson"
		testObject.age = 27
		testObject.employee = Employee()
		testObject.employee?.name = "Lucas"
		testObject.employee?.age = 35
		testObject.boss = Boss()
		testObject.boss?.bad = false
		testObject.boss?.employees = Array()
		testObject.boss?.employees?.append(emp1)
		testObject.boss?.employees?.append(emp2)
		
		let writer = JsonWriter()
        let jsonData: Data? = writer.write(anyObject: testObject)
		
		let jsonObject = try! JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! [String: AnyObject]
		
		assert(testObject.name == jsonObject["name"] as? String)
		assert(testObject.age == jsonObject["age"] as? Int)
		
		let employee = jsonObject["employee"] as! [String: AnyObject]
		assert(testObject.employee?.name == employee["name"] as? String)
		assert(testObject.employee?.age == employee["age"] as? Int)
		
		let boss = jsonObject["boss"] as! [String: AnyObject]
		let employees = boss["employees"] as! [[String: AnyObject]]
		assert(testObject.boss?.employees?[0].name == employees[0]["name"] as? String)
		assert(testObject.boss?.employees?[0].age == employees[0]["age"] as? Int)
		
		assert(testObject.boss?.employees?[1].name == employees[1]["name"] as? String)
		assert(testObject.boss?.employees?[1].age == employees[1]["age"] as? Int)
	}
	
	func testWriterWithNullField() {
		let config = JsonConfig()
		config.shouldIncludeNullValueKeys = false
		
		let testObject = TestObject()
		
		let writer = JsonWriter()
        var jsonString: String? = writer.write(anyObject: testObject, withConfig: config)
		
		var dic = try! JSONSerialization.jsonObject(with: jsonString!.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
		
		assert(!dic.keys.contains("employee"))
		assert(!dic.keys.contains("boss"))
		assert(!dic.keys.contains("employees"))
		
		testObject.employee = Employee()
		
		jsonString = writer.write(anyObject: testObject, withConfig: config)
		
		dic = try! JSONSerialization.jsonObject(with: jsonString!.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
		
		assert(!(dic["employee"] as! Dictionary<String, AnyObject>).keys.contains("name"))
	}
	
	func testJsonWithNSNull() {
		let jsonString = "{ \"name\": null, \"age\": null }"
		let employee: Employee? = JsonParser().parse(string: jsonString)
		
		assert(employee?.name == nil)
	}        
}

@objc(Employee) class Employee: NSObject {
    @objc fileprivate(set) dynamic var name: String?
    @objc fileprivate(set) dynamic var age: Int = 0
	
	required override init() {
		super.init()
	}
}

class Boss : Employee {
    @objc fileprivate(set) dynamic var bad: Bool = false
    @objc fileprivate(set) dynamic var employees: [Employee]?
	
	required init() {
		super.init()
	}
}

class TestObject : NSObject {
    @objc fileprivate(set) dynamic var name: String?
    @objc fileprivate(set) dynamic var age: Int = 0
    @objc fileprivate(set) dynamic var height: Float = 0
    @objc fileprivate(set) dynamic var employee: Employee?
    @objc fileprivate(set) dynamic var boss: Boss?
    @objc fileprivate(set) dynamic var employees: [Employee]?
	
	required override init() {
		super.init()
	}
}
