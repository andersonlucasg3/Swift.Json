[![Build Status](https://travis-ci.org/andersonlucasg3/Swift.Json.svg?branch=master)](https://travis-ci.org/andersonlucasg3/Swift.Json)

# Swift.Json
Json auto-parsing for Swift.

##### Examples
For using the JsonParser and JsonWriter classes you just need to declare your swift classes where all the properties are `@objc dynamic` and the class **MUST** extend from `NSObject`.
Other thing is that `Obj-c` representable objects may be optional, but non `Obj-c` representable objects **MUST** be defined non optional.
The `@objc dynamic` diretive will obligate you to define it right in swift <=3.x, but in swift 4.x only `@objc` is required.

###### Writing example:
Example of the implementation for converting objects to string.
```swift
import Swift_Json // very important

class Employee: NSObject {
    @objc fileprivate(set) dynamic var name: String?
    @objc fileprivate(set) dynamic var age: Int = 0
}

class Boss: Employee {
    @objc fileprivate(set) dynamic var employees: [Employee]?
}

let employee1: Employee = Employee()
employee1.name = "John Apple Juice"
employee1.age = 35

let boss: Boss = Boss()
boss.name = "Steve James Apple Orange Juice"
boss.age = 65
boss.employees?.append(employee1)

let writer = JsonWriter()
let jsonString: String = writer.write(boss)
```

###### Parsing example:
Example of the implementation for converting string to objects.
Obs: Using the same classes from above.
```swift
let jsonString: String = // json string

let parser = JsonParser()
let boss: Boss = parser.parse(string: jsonString)

assert(boss.name == "Steve James Apple Orange Juice")
assert(boss.age == 65)
assert(boss.employees![0].name == "John Apple Juice")
assert(boss.employees![0].age == 35)
```

###### Naming Convention:
Usually, the web use the snake_case pattern to name the properties, while Swift uses the camelCase pattern. Its possible to make the JsonWriter/JsonParser automatically do this conversion by passing a JsonConfig object, with a functional CasePatternConverter associated, in the write/parse operation. The Swift.Json lib provides you with two implementations for CasePatternConverter: CamelCaseConverter and SnakeCaseConverter.
Obs: Using the same classes from above.
```swift
class Programmer: Employee {
    @objc private(set) dynamic var coffeeLevel: Int = 0
}

let jsonString: String = // json string with snake_case naming convention (ex: "coffee_level")

let config = JsonConfig()
config.casePatternConverter = SnakeCaseConverter()

//Parsing: convert the json's "coffee_level" to programmers's "coffeeLevel".
let programmer: Programmer = JsonParser().parse(string: jsonString, withConfig:config)

//Writing: convert the programmers's "coffeeLevel" to json's "coffee_level"
let programmerJsonString: String = JsonWriter().write(anyObject: programmer, withConfig: config)
```

Any doubts, post an issue or create a pull request. Pull requests are welcome.
Thanks.
