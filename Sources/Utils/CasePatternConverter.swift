//
//  CasePatternConverter.swift
//  SwiftJson
//
//  Created by Jorge Luis on 31/12/17.
//

import Foundation

/**
 * CasePatternConversionBlock is the block which is called just before the convert(_:) method return the key converted to the JsonConfig.
 * - Parameter key: the field name String, provenient from a json file or an object
 * - Parameter field: the key converted to the designated pattern by the converToField(_:) method.
 */
public typealias CasePatternConversionBlock = ((_ key: String, _ field: String) -> String)

/// Protocol used by JsonConfig to automatically convert the naming conventions on swift object's properties name to match the json's properties name, and vice versa
public protocol CasePatternConverter: class {
    ///Called only in the convert(_:) method, just after the key field become converted by the converToField method, and then its return is used as the real converted value.
    var complementaryConversion: CasePatternConversionBlock? {get set}
    
    ///Convert the key to designated case pattern without calling the complementary conversion method
    func convertToField(_ key: String) -> String
}

public extension CasePatternConverter {
    ///Convert the key to designated case pattern calling the complementary conversion method
    public func convert(_ key: String) -> String {
        let field = self.convertToField(key)
        return self.complementaryConversion?(key,field) ?? field
    }
}

/**
 * Default implementation to convert any swift's object field name to camelCase convention (all words Capitalized, except for the first, without any separator character)
 * Example: "sadistic_sociopath" and "full_fake_name" will become, respectively: "sadisticSociopath" and "fullFakeName"
 */
open class CamelCaseConverter: CasePatternConverter {
    private static let regex = try? NSRegularExpression.init(pattern: "[^a-z^A-Z]+(.)", options: .useUnixLineSeparators)
    
    public var complementaryConversion: CasePatternConversionBlock?
    
    public init(_ block: CasePatternConversionBlock? = nil) {
        self.complementaryConversion = block
    }
    
    public func convertToField(_ key: String) -> String {
        var nsTarget = NSString(string:key)
        CamelCaseConverter.regex?.matches(in: key, options: .reportCompletion, range: NSMakeRange(0, key.count)).reversed().forEach({
            nsTarget = NSString(string:nsTarget.replacingCharacters(in: $0.range, with: nsTarget.substring(with: $0.range(at:1)).uppercased()))
        })
        return nsTarget.replacingCharacters(in: NSMakeRange(0, 1), with: nsTarget.substring(with: NSMakeRange(0, 1)).lowercased())
    }
}

/**
 * Default implementation to convert any swift's object field name to snake_case convention (all letter lowercase, separated by underscore)
 * Example: "sadisticSociopath" and "fullFakeName" will become, respectively: "sadistic_sociopath" and "full_fake_name"
 */
open class SnakeCaseConverter: CasePatternConverter {
    private static let firstStepPattern = try? NSRegularExpression.init(pattern: "[- _]+(.)", options: .useUnixLineSeparators)
    private static let secondStepPattern = try? NSRegularExpression.init(pattern: "([^-^_^ ])([A-Z])", options: .useUnixLineSeparators)
    
    public var complementaryConversion: CasePatternConversionBlock?
    
    public init(_ block: CasePatternConversionBlock? = nil) {
        self.complementaryConversion = block
    }
    
    public func convertToField(_ key: String) -> String {        
        let nsTarget = NSMutableString(string:key)
        SnakeCaseConverter.firstStepPattern?.replaceMatches(in: nsTarget, options: .reportCompletion, range: NSMakeRange(0, nsTarget.length), withTemplate: "_$1")
        SnakeCaseConverter.secondStepPattern?.replaceMatches(in: nsTarget, options: .reportCompletion, range: NSMakeRange(0, nsTarget.length), withTemplate: "$1_$2")
        return (nsTarget as String).lowercased()
    }
}
