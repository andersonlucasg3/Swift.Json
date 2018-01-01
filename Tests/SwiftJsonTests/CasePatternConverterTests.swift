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

