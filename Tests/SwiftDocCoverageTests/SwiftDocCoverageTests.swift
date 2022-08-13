import XCTest
//import class Foundation.Bundle
@testable import SwiftDocCoverage

import SwiftSyntax
import SwiftSyntaxParser


/// String errors
extension String : LocalizedError {
    public var errorDescription: String? { return self }
}

final class CommonTests: XCTestCase {
    
    func test_typealias() throws {
        let source = try Source(source: "typealias SSN = Int")
        XCTAssert(source.declarations[0].description == "SSN")
    }
    
    func test_associatedtype() throws {
        let source = try Source(source: """
        protocol Container {
            associatedtype Item
            associatedtype Element: Equatable
            associatedtype Suffix: SuffixableContainer where Suffix.Item == Item
        }
        """)
        XCTAssert(source.declarations.count == 4)
        XCTAssert(source.declarations[0].description == "Container")
        XCTAssert(source.declarations[1].description == "Container.Item")
        XCTAssert(source.declarations[2].description == "Container.Element")
        XCTAssert(source.declarations[3].description == "Container.Suffix")
    }
    
    func test_class() throws {
        let source = try Source(source: """
        class Vehicle {}
        class Bicycle: Vehicle {}
        class Stack<Element> {}
        """)
        XCTAssert(source.declarations.count == 3)
        XCTAssert(source.declarations[0].description == "Vehicle")
        XCTAssert(source.declarations[1].description == "Bicycle")
        XCTAssert(source.declarations[2].description == "Stack<Element>")
    }
    
    func test_struct() throws {
        let source = try Source(source: """
        struct Book {}
        struct Person: FullyNamed {}
        struct Stack<Element> {}
        """)
        XCTAssert(source.declarations.count == 3)
        XCTAssert(source.declarations[0].description == "Book")
        XCTAssert(source.declarations[1].description == "Person")
        XCTAssert(source.declarations[2].description == "Stack<Element>")
    }
    
    func test_protocol() throws {
        let source = try Source(source: """
        protocol Container {}
        protocol InheritingProtocol: SomeProtocol, AnotherProtocol {}
        protocol SomeClassOnlyProtocol: AnyObject, SomeInheritedProtocol {}
        @objc protocol CounterDataSource {}
        """)
        XCTAssert(source.declarations.count == 4)
        XCTAssert(source.declarations[0].description == "Container")
        XCTAssert(source.declarations[1].description == "InheritingProtocol")
        XCTAssert(source.declarations[2].description == "SomeClassOnlyProtocol")
        XCTAssert(source.declarations[3].description == "CounterDataSource")
    }
    
    func test_extention() throws {
        let source = try Source(source: """
        extension Container {}
        extension SomeType: SomeProtocol, AnotherProtocol {}
        extension Array: TextRepresentable where Element: TextRepresentable {}
        """)
        XCTAssert(source.declarations.count == 3)
        XCTAssert(source.declarations[0].description == "Container")
        XCTAssert(source.declarations[1].description == "SomeType")
        XCTAssert(source.declarations[2].description == "Array")
    }
    
    func test_function() throws {
        let source = try Source(source: """
        func greet(person: String) -> String { return person; }
        func someFunction(argumentLabel parameterName: Int) {}
        func arithmeticMean(_ numbers: Double...) -> Double {}
        func swapTwoValues<T>(_ a: inout T, _ b: inout T) {}
        enum CompassPoint {
            mutating func turnNorth() {}
            static func + (left: Vector2D, right: Vector2D) -> Vector2D {}
        }
        """)
        XCTAssert(source.declarations.count == 7)
        XCTAssert(source.declarations[0].description == "greet(person: String) -> String")
        XCTAssert(source.declarations[1].description == "someFunction(argumentLabel parameterName: Int)")
        XCTAssert(source.declarations[2].description == "arithmeticMean(_ numbers: Double...) -> Double")
        XCTAssert(source.declarations[3].description == "swapTwoValues<T>(_ a: inout T, _ b: inout T)")
        XCTAssert(source.declarations[4].description == "CompassPoint")
        XCTAssert(source.declarations[5].description == "CompassPoint.turnNorth()")
        XCTAssert(source.declarations[6].description == "CompassPoint.+(left: Vector2D, right: Vector2D) -> Vector2D")
    }
    
    func test_initializer() throws {
        let source = try Source(source: """
        struct Color {
            init() {}
            override init() {}
            init(fromFahrenheit fahrenheit: Double) {}
            init(_ celsius: Double) {}
            init?(species: String) {}
            init<Item>(item: Item) {}
        }
        """)
        XCTAssert(source.declarations.count == 7)
        XCTAssert(source.declarations[0].description == "Color")
        XCTAssert(source.declarations[1].description == "Color.init()")
        XCTAssert(source.declarations[2].description == "Color.init()")
        XCTAssert(source.declarations[3].description == "Color.init(fromFahrenheit fahrenheit: Double)")
        XCTAssert(source.declarations[4].description == "Color.init(_ celsius: Double)")
        XCTAssert(source.declarations[5].description == "Color.init?(species: String)")
        XCTAssert(source.declarations[6].description == "Color.init<Item>(item: Item)")
    }
    
    func test_subscript() throws {
        let source = try Source(source: """
        struct TimesTable {
            subscript(index: Int) -> Int { return multiplier * index }
            subscript(row: Int, column: Int) -> Double {}
            static subscript(n: Int) -> Planet {}
            subscript<Item>(n: Int) -> Item {}
        }
        """)
        XCTAssert(source.declarations.count == 5)
        XCTAssert(source.declarations[0].description == "TimesTable")
        XCTAssert(source.declarations[1].description == "TimesTable.subscript(index: Int) -> Int")
        XCTAssert(source.declarations[2].description == "TimesTable.subscript(row: Int, column: Int) -> Double")
        XCTAssert(source.declarations[3].description == "TimesTable.subscript(n: Int) -> Planet")
        XCTAssert(source.declarations[4].description == "TimesTable.subscript<Item>(n: Int) -> Item")
    }
    
    func test_variable() throws {
        let source = try Source(source: """
        let name: String
        let id: Int = 123
        let a, b, c: Int
        var volume: Double { return width * height * depth }
        lazy var importer = DataImporter()
        class Math {
            var mathFunction: (Int, Int) -> Int = addTwoInts
        }
        """)
        XCTAssert(source.declarations.count == 7)
        XCTAssert(source.declarations[0].description == "name")
        XCTAssert(source.declarations[1].description == "id")
        XCTAssert(source.declarations[2].description == "a,b,c")
        XCTAssert(source.declarations[3].description == "volume")
        XCTAssert(source.declarations[4].description == "importer")
        XCTAssert(source.declarations[5].description == "Math")
        XCTAssert(source.declarations[6].description == "Math.mathFunction")
    }
    
    func test_enum() throws {
        let source = try Source(source: """
        enum CompassPoint {
            case north, south
            case east
            case west
            case upc(Int, Int, Int, Int)
        }
        enum Planet<Item> {}
        """)
        XCTAssert(source.declarations.count == 6)
        XCTAssert(source.declarations[0].description == "CompassPoint")
        XCTAssert(source.declarations[1].description == "CompassPoint.north,south")
        XCTAssert(source.declarations[2].description == "CompassPoint.east")
        XCTAssert(source.declarations[3].description == "CompassPoint.west")
        XCTAssert(source.declarations[4].description == "CompassPoint.upc(Int, Int, Int, Int)")
        XCTAssert(source.declarations[5].description == "Planet<Item>")
    }
    
    func test_precedencegroup_operator() throws {
        let source = try Source(source: """
        precedencegroup ForwardPipe {
            associativity: left
        }
        infix operator => : ForwardPipe
        """)
        XCTAssert(source.declarations.count == 2)
        XCTAssert(source.declarations[0].description == "precedencegroup ForwardPipe")
        XCTAssert(source.declarations[1].description == "operator =>")
    }
}

final class FileTests: XCTestCase {
    
    let resourcesPath = Bundle.module.path(forResource: "Resources", ofType: nil)!
    let userFileURL = Bundle.module.url(forResource: "User", withExtension: "swift", subdirectory: "Resources/Test")!
    
    func test_scan() throws {
        let urls = try scan(path: resourcesPath)
        XCTAssert(urls.count == 1)
    }
    
    func test_scan_not_found() throws {
        XCTAssertThrowsError(try scan(path: "bad/path")) { error in
            XCTAssert(error as? ScanError == .fileNotFound)
        }
    }
    
    func test_file() throws {
        let source = try Source(fileURL: userFileURL)
        source.declarations.forEach {
            print($0)
        }
    }
}
