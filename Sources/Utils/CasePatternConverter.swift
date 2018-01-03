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
    public var complementaryConversion: CasePatternConversionBlock?
    
    public init(_ block: CasePatternConversionBlock? = nil) {
        self.complementaryConversion = block
    }
    
    public func convertToField(_ key: String) -> String {
        let pattern = "[^a-z^A-Z]+(.)"
        var nsTarget = NSString(string:key)
        let regex = try? NSRegularExpression.init(pattern: pattern, options: .useUnixLineSeparators)
        regex?.matches(in: key, options: .reportCompletion, range: NSMakeRange(0, key.count)).reversed().forEach({
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
    public var complementaryConversion: CasePatternConversionBlock?
    
    public init(_ block: CasePatternConversionBlock? = nil) {
        self.complementaryConversion = block
    }
    
    public func convertToField(_ key: String) -> String {
        let patternsAndTemplates: [String:String] = ["[^a-z^A-Z]+(.)":"_$1", "([a-z])([A-Z])":"$1_$2", "([A-Z])([A-Z])":"$1_$2"]
        let nsTarget = NSMutableString(string:key)
        patternsAndTemplates.keys.forEach { (pattern) in
            let regex = try? NSRegularExpression.init(pattern: pattern, options: .useUnixLineSeparators)
            regex?.replaceMatches(in: nsTarget, options: .reportCompletion, range: NSMakeRange(0, nsTarget.length), withTemplate: patternsAndTemplates[pattern]!)
        }
        return (nsTarget as String).lowercased()
    }
}
