//
//  SwiftJsonArrayTests.swift
//  SwiftJsonTests
//
//  Created by Anderson Lucas de Castro Ramos on 27/11/2017.
//

import XCTest
@testable import SwiftJson

class SwiftJsonArrayTests: XCTestCase {
    
    func testArrayRead() {
        let jsonString = try! String(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "jsonArray", ofType: "json")!)
        
        let parser = JsonParser()
        guard let array: [Employee] = parser.parse(string: jsonString) else {
            assertionFailure("array is Nil")
            return
        }
        
        assert(array[0].name == "Anderson")
        assert(array[1].name == "Bruna")
    
        let writer = JsonWriter()
        guard let otherJsonString: String = writer.write(anyArray: array) else {
            assertionFailure("other json string is Nil")
            return
        }
        
        guard let otherArray: [Employee] = parser.parse(string: otherJsonString) else {
            assertionFailure("other array is Nil")
            return
        }
        
        assert(array[0].name == otherArray[0].name)
        assert(array[1].name == otherArray[1].name)
    }
    
    func testArrayReadWritePrimitives() {
        let parser = JsonParser()
        let writer = JsonWriter()
        
        let intArray = [1, 2, 3, 4, 5]
        
        let intString: String? = writer.write(anyArray: intArray)
        let otherIntArray: [Int]? = parser.parse(string: intString!)
        
        assert(intArray.elementsEqual(otherIntArray!))
        
        let doubleArray = [1.44, 2.55]
        
        let doubleString: String? = writer.write(anyArray: doubleArray)
        let otherDoubleArray: [Double]? = parser.parse(string: doubleString!)
        
        assert(doubleArray.elementsEqual(otherDoubleArray!))
        
        let stringArray = ["Anderson", "Bruna"]
        
        let stringString: String? = writer.write(anyArray: stringArray)
        let otherStringArray: [String]? = parser.parse(string: stringString!)
        
        assert(stringArray.elementsEqual(otherStringArray!))
    }
}
