//
//  CasePatternConverter.swift
//  SwiftJson
//
//  Created by Jorge Luis on 31/12/17.
//

import Foundation

/// CasePatternConversionBlock is the block which is called just before the convert(_:) method return the key converted to the JsonConfig.
///
/// - Parameters:
///   - key: the field name String, provenient from a json file or an object
///   - field: the key converted to the designated pattern by the converToField(_:) method.
public typealias CasePatternConversionBlock = ((_ key: String, _ field: String) -> String)

public protocol CasePatternConverter: class {
    /// Called just after the key field become converted by the converToField method
    /// Its return is used as the real converted value in the convert(_:) method.
    var complementaryConversion: CasePatternConversionBlock? {get set}
    
    /// Convert the case pattern of the given field key
    ///
    /// - Parameters:
    ///   - key: the field name String, provenient from a json file or an object
    func convertToField(_ key: String) -> String
}

extension CasePatternConverter {
    init(_ block: CasePatternConversionBlock? = nil) {
        self.init()
        self.complementaryConversion = block
    }
    
    func convert(_ key: String) -> String {
        let field = self.convertToField(key)
        return self.complementaryConversion?(key,field) ?? field
    }
}

/// Default implementation to convert any field key to camelCase convention (all words Capitalized, except for the first, without any separator character)
///
/// Example: "_full-grand_MOTHERS-name" and "RANDOM-phone Number" will become, respectively: "fullGrandMothersName" and "randomPhoneNumber"
open class CamelCaseConverter: CasePatternConverter {
    public var complementaryConversion: CasePatternConversionBlock?
    
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

/// Default implementation to convert any field key to snake_case convention (all letter lowercase, separated by underscore)
///
/// Example: "_full-grand_MOTHERS-name" and "RANDOM-phone Number" will become, respectively: "_full_grand_mothers_name" and "random_phone_number"
open class SnakeCaseConverter: CasePatternConverter {
    public var complementaryConversion: CasePatternConversionBlock?
    
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
