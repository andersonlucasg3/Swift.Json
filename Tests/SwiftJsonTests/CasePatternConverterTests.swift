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
        
        let complementaryConversion: CasePatternConversionBlock? = { (key,convertedKey) -> String in
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
        
        let complementaryConversion: CasePatternConversionBlock? = { (key,convertedKey) -> String in
            let keySnakeCased = snakeCased[toConvert.index(of: key)!]
            assert(keySnakeCased == convertedKey)
            return "_" + convertedKey + "_"
        }
        
        let converter = SnakeCaseConverter(complementaryConversion)
        
        toConvert.enumerated().forEach({
            assert(converter.convert($0.element) == fullyConverted[$0.offset])
        })
    }
}


