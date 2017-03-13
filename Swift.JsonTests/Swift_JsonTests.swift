//
//  Swift_JsonTests.swift
//  Swift.JsonTests
//
//  Created by Anderson Lucas C. Ramos on 13/03/17.
//
//

import XCTest
@testable import SwiftJson

class Swift_JsonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testJsonParser() {
		let jsonString = try! String(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "jsonObject", ofType: "json")!)
		
		let config = JsonConfig<TestObject>()
		config.set(forDataType: "Date") { (value, key) -> AnyObject? in
			if key == "date" {
				let formatter = DateFormatter()
				formatter.dateFormat = "dd/MM/yyyy"
				return formatter.date(from: value as! String) as AnyObject
			}
			return nil
		}
		
		let testObject: TestObject? = JsonParser.parse(string: jsonString, withConfig: config)
		assert(testObject != nil)
		assert(testObject?.name == "Anderson")
		assert(testObject?.age == 25)
		assert(testObject?.height == 1.85)
		assert(testObject?.employee?.name == "Jorge Xavier")
		assert(testObject?.employee?.age == 20)
		assert(testObject?.boss?.name == "Thiago N.")
		assert(testObject?.boss?.age == 55)
		assert(testObject?.boss?.bad == true)
	}
}

class Employee: NSObject {
	fileprivate(set) dynamic var name: String = ""
	fileprivate(set) dynamic var age: Int = 0
	
	required override init() {
		super.init()
	}
}

class Boss : Employee {
	fileprivate(set) dynamic var bad: Bool = false
	
	required init() {
		super.init()
	}
}

class TestObject : NSObject {
	fileprivate(set) dynamic var name: String?
	fileprivate(set) dynamic var age: Int = 0
	fileprivate(set) dynamic var height: Float = 0
	fileprivate(set) dynamic var date: Date?
	fileprivate(set) dynamic var employee: Employee?
	fileprivate(set) dynamic var boss: Boss?
	
	required override init() {
		super.init()
	}
}
