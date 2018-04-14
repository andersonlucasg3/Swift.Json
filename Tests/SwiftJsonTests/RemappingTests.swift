//
//  RemappingTests.swift
//  SwiftJsonTests
//
//  Created by Anderson Lucas de Castro Ramos on 14/04/2018.
//

import XCTest
@testable import SwiftJson

class RemappingTests: XCTestCase {
    func testRemapping() {
        let jsonString = try! String(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "jsonObject", ofType: "json")!)
        
        let config = JsonConfig()
        config.set(fromKey: "subtitle", to: "description")
        config.set(fromKey: "subtitleText", to: "description_text")
        config.set(fromKey: "subtitle_text", to: "descriptionText")
        let parser = JsonParser()
        
        let employee: EmployeeRemapping? = parser.parse(string: jsonString, withConfig: config)
        XCTAssertNotNil(employee)
        XCTAssertNotNil(employee?.subtitle)
        XCTAssertNotNil(employee?.subtitleText)
        XCTAssertNotNil(employee?.subtitle_text)
        assert(employee?.subtitle == "É um cara muito legal 1")
        assert(employee?.subtitleText == "É um cara muito legal 2")
        assert(employee?.subtitle_text == "É um cara muito legal 3")
    }
}

class EmployeeRemapping: Employee {
    @objc var subtitle: String?
    @objc var subtitleText: String?
    @objc var subtitle_text: String?
}
