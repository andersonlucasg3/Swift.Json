//
//  CasePatternConverterTests.swift
//  SwiftJson
//
//  Created by Jorge Luis on 01/01/18.
//

import XCTest
@testable import SwiftJson

class CasePatternConverterTests: XCTestCase {
    
    func testConvertToCamelCaseWithComplementaryConversion() {
        let toConvert = ["test-property-one","test_property_two","Test-Property-Three","Test_Property_Four","TestPropertyFive","test - propety - six"]
        
        let camelCased = ["testPropertyOne","testPropertyTwo","testPropertyThree","testPropertyFour","testPropertyFive","testPropetySix"]
    
        let fullyConverted = ["_testPropertyOne_","_testPropertyTwo_","_testPropertyThree_","_testPropertyFour_","_testPropertyFive_","_testPropetySix_"]
        
        let complementaryConversion: NamingConventionConversionBlock? = { (key,convertedKey) -> String in
            let keyCamelCased = camelCased[toConvert.index(of: key)!]
            assert(keyCamelCased == convertedKey)
            return "_" + convertedKey + "_"
        }
        
        let converter = CamelCaseConverter(complementaryConversion)
        
        toConvert.enumerated().forEach({
            assert(converter.convert($0.element) == fullyConverted[$0.offset])
        })
    }
    
    func testConvertToSnakeCaseWithComplementaryConversion() {
        let toConvert = ["test-property-one","testPropertyTwo","Test-Property-Three","Test_Property_Four","TestPropertyFive","test - propety - six"]
        
        let snakeCased = ["test_property_one","test_property_two","test_property_three","test_property_four","test_property_five","test_propety_six"]
        
        let fullyConverted = ["_test_property_one_","_test_property_two_","_test_property_three_","_test_property_four_","_test_property_five_","_test_propety_six_"]
        
        let complementaryConversion: NamingConventionConversionBlock? = { (key,convertedKey) -> String in
            let keySnakeCased = snakeCased[toConvert.index(of: key)!]
            assert(keySnakeCased == convertedKey)
            return "_" + convertedKey + "_"
        }
        
        let converter = SnakeCaseConverter(complementaryConversion)
        
        toConvert.enumerated().forEach({
            assert(converter.convert($0.element) == fullyConverted[$0.offset])
        })
    }
    
    #if Xcode
    func testJsonParser() {
        let jsonString = try! String(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "snakeCasedJsonObject", ofType: "json")!)
        
        let config = JsonConfig()
        config.set(forDataType: "Date") { (value, key) -> AnyObject? in
            if key == "date" {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                return formatter.date(from: value as! String) as AnyObject
            }
            return nil
        }
        config.casePatternConverter = CasePatternConverter(json: SnakeCaseConverter(), object: nil)
        
        let parser = JsonParser()
        let testObject: CTestObject? = parser.parse(string: jsonString, withConfig: config)
        assert(testObject != nil)
        assert(testObject?.fullFakeName == "Anderson")
        assert(testObject?.lookingAge == 25) 
        assert(testObject?.apparentHeight == 1.85)
        assert(testObject?.mostDangerousEmployee?.fullFakeName == "Jorge Xavier")
        assert(testObject?.mostDangerousEmployee?.lookingAge == 20)
        assert(testObject?.bigBoss?.fullFakeName == "Thiago N.")
        assert(testObject?.bigBoss?.lookingAge == 55)
        assert(testObject?.bigBoss?.sadisticSociopath == true)
        assert(testObject!.employees!.count > 0)
        assert(testObject!.employees![0].fullFakeName == "Jorge Xavier")        
    }
    #endif
    
    func testJsonWriter() {
        let emp1 = CEmployee()
        emp1.fullFakeName = "Emp 1"
        emp1.lookingAge = 55
        let emp2 = CEmployee()
        emp2.fullFakeName = "Emp 2"
        emp2.lookingAge = 35
        
        let testObject = CTestObject()
        testObject.fullFakeName = "Anderson"
        testObject.lookingAge = 27
        testObject.mostDangerousEmployee = CEmployee()
        testObject.mostDangerousEmployee?.fullFakeName = "Lucas"
        testObject.mostDangerousEmployee?.lookingAge = 35
        testObject.bigBoss = CBoss()
        testObject.bigBoss?.sadisticSociopath = false
        testObject.bigBoss?.employees = Array()
        testObject.bigBoss?.employees?.append(emp1)
        testObject.bigBoss?.employees?.append(emp2)
        
        let config = JsonConfig()
        config.casePatternConverter = CasePatternConverter(json: SnakeCaseConverter(), object: nil)
        let jsonData: Data? = JsonWriter().write(anyObject: testObject, withConfig: config)
        
        let jsonObject = try! JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! [String: AnyObject]
        
        assert(testObject.fullFakeName == jsonObject["full_fake_name"] as? String)
        assert(testObject.lookingAge == jsonObject["looking_age"] as? Int)
        
        let employee = jsonObject["most_dangerous_employee"] as! [String: AnyObject]
        assert(testObject.mostDangerousEmployee?.fullFakeName == employee["full_fake_name"] as? String)
        assert(testObject.mostDangerousEmployee?.lookingAge == employee["looking_age"] as? Int)
        
        let boss = jsonObject["big_boss"] as! [String: AnyObject]
        let employees = boss["employees"] as! [[String: AnyObject]]
        assert(testObject.bigBoss?.employees?[0].fullFakeName == employees[0]["full_fake_name"] as? String)
        assert(testObject.bigBoss?.employees?[0].lookingAge == employees[0]["looking_age"] as? Int)
        
        assert(testObject.bigBoss?.employees?[1].fullFakeName == employees[1]["full_fake_name"] as? String)
        assert(testObject.bigBoss?.employees?[1].lookingAge == employees[1]["looking_age"] as? Int)
    }
    
    func testArrayRead() {
        let jsonString = try! String(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "snakeCasedJsonArray", ofType: "json")!)
        let config = JsonConfig(CasePatternConverter(json: SnakeCaseConverter(), object:nil))
        let parser = JsonParser()
        guard let array: [CTestObject] = parser.parse(string: jsonString, withConfig: config) else {
            assertionFailure("array is Nil")
            return
        }
        
        assert(array[0].fullFakeName == "Anderson")
        assert(array[1].fullFakeName == "Julio")
        assert(array[2].fullFakeName == "Jorge")
        
        let writer = JsonWriter()
        guard let otherJsonString: String = writer.write(anyArray: array, withConfig: config) else {
            assertionFailure("other json string is Nil")
            return
        }
        
        guard let otherArray: [CTestObject] = parser.parse(string: otherJsonString, withConfig: config) else {
            assertionFailure("other array is Nil")
            return
        }
        
        assert(array[0].fullFakeName == otherArray[0].fullFakeName)
        assert(array[1].fullFakeName == otherArray[1].fullFakeName)
        assert(array[2].fullFakeName == otherArray[2].fullFakeName)
    }
}


@objc(CEmployee) class CEmployee: NSObject {
    @objc fileprivate(set) dynamic var fullFakeName: String?
    @objc fileprivate(set) dynamic var lookingAge: Int = 0
    
    required override init() {
        super.init()
    }
}

class CBoss : CEmployee {
    @objc fileprivate(set) dynamic var sadisticSociopath: Bool = false
    @objc fileprivate(set) dynamic var employees: [CEmployee]?
    
    required init() {
        super.init()
    }
}

class CTestObject : NSObject {
    @objc fileprivate(set) dynamic var fullFakeName: String?
    @objc fileprivate(set) dynamic var lookingAge: Int = 0
    @objc fileprivate(set) dynamic var apparentHeight: Float = 0
    @objc fileprivate(set) dynamic var mostDangerousEmployee: CEmployee?
    @objc fileprivate(set) dynamic var bigBoss: CBoss?
    @objc fileprivate(set) dynamic var employees: [CEmployee]?
    
    required override init() {
        super.init()
    }
}

