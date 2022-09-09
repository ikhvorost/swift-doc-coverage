import XCTest
@testable import SwiftDocCoverage


final class DeclarationTests: XCTestCase {
    
    func test_typealias() throws {
        let source = try Source(source: """
        typealias SSN = Int
        class Audio {
            typealias AudioSample = UInt16
        }
        """)
        XCTAssert(source.declarations.count == 3)
        XCTAssert(source.declarations[0].name == "SSN")
        XCTAssert(source.declarations[1].name == "Audio")
        XCTAssert(source.declarations[2].name == "Audio.AudioSample")
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
        XCTAssert(source.declarations[0].name == "Container")
        XCTAssert(source.declarations[1].name == "Container.Item")
        XCTAssert(source.declarations[2].name == "Container.Element")
        XCTAssert(source.declarations[3].name == "Container.Suffix")
    }
    
    func test_if_endif() throws {
        let source = try Source(source: """
        #if compiler(>=5)
            class A {}
        #endif
        #if swift(>=4.2)
            class B {}
        #elseif compiler(>=5) && swift(<5)
            class C {}
        #endif
        #if DEBUG
            class D {}
        #else
            class E {}
        #endif
        """)
        XCTAssert(source.declarations.count == 5)
        XCTAssert(source.declarations[0].name == "A")
        XCTAssert(source.declarations[1].name == "B")
        XCTAssert(source.declarations[2].name == "C")
        XCTAssert(source.declarations[3].name == "D")
        XCTAssert(source.declarations[4].name == "E")
    }
    
    func test_class_actor() throws {
        let source = try Source(source: """
        class Vehicle {}
        class Bicycle: Vehicle {}
        class Stack<Element> {}
        actor UserStorage {}
        """)
        XCTAssert(source.declarations.count == 4)
        XCTAssert(source.declarations[0].name == "Vehicle")
        XCTAssert(source.declarations[1].name == "Bicycle")
        XCTAssert(source.declarations[2].name == "Stack<Element>")
        XCTAssert(source.declarations[3].name == "UserStorage")
    }
    
    func test_struct() throws {
        let source = try Source(source: """
        struct Book {}
        struct Person: FullyNamed {}
        struct Stack<Element> {}
        """)
        XCTAssert(source.declarations.count == 3)
        XCTAssert(source.declarations[0].name == "Book")
        XCTAssert(source.declarations[1].name == "Person")
        XCTAssert(source.declarations[2].name == "Stack<Element>")
    }
    
    func test_protocol() throws {
        let source = try Source(source: """
        protocol Container {}
        protocol InheritingProtocol: SomeProtocol, AnotherProtocol {}
        protocol SomeClassOnlyProtocol: AnyObject, SomeInheritedProtocol {}
        @objc protocol CounterDataSource {}
        """)
        XCTAssert(source.declarations.count == 4)
        XCTAssert(source.declarations[0].name == "Container")
        XCTAssert(source.declarations[1].name == "InheritingProtocol")
        XCTAssert(source.declarations[2].name == "SomeClassOnlyProtocol")
        XCTAssert(source.declarations[3].name == "CounterDataSource")
    }
    
    func test_extention() throws {
        let source = try Source(source: """
        extension Container {}
        extension SomeType: SomeProtocol, AnotherProtocol {}
        extension Array: TextRepresentable where Element: TextRepresentable {}
        """)
        XCTAssert(source.declarations.count == 3)
        XCTAssert(source.declarations[0].name == "Container")
        XCTAssert(source.declarations[1].name == "SomeType")
        XCTAssert(source.declarations[2].name == "Array")
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
        XCTAssert(source.declarations[0].name == "greet(person: String) -> String")
        XCTAssert(source.declarations[1].name == "someFunction(argumentLabel parameterName: Int)")
        XCTAssert(source.declarations[2].name == "arithmeticMean(_ numbers: Double...) -> Double")
        XCTAssert(source.declarations[3].name == "swapTwoValues<T>(_ a: inout T, _ b: inout T)")
        XCTAssert(source.declarations[4].name == "CompassPoint")
        XCTAssert(source.declarations[5].name == "CompassPoint.turnNorth()")
        XCTAssert(source.declarations[6].name == "CompassPoint.+(left: Vector2D, right: Vector2D) -> Vector2D")
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
        XCTAssert(source.declarations[0].name == "Color")
        XCTAssert(source.declarations[1].name == "Color.init()")
        XCTAssert(source.declarations[2].name == "Color.init()")
        XCTAssert(source.declarations[3].name == "Color.init(fromFahrenheit fahrenheit: Double)")
        XCTAssert(source.declarations[4].name == "Color.init(_ celsius: Double)")
        XCTAssert(source.declarations[5].name == "Color.init?(species: String)")
        XCTAssert(source.declarations[6].name == "Color.init<Item>(item: Item)")
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
        XCTAssert(source.declarations[0].name == "TimesTable")
        XCTAssert(source.declarations[1].name == "TimesTable.subscript(index: Int) -> Int")
        XCTAssert(source.declarations[2].name == "TimesTable.subscript(row: Int, column: Int) -> Double")
        XCTAssert(source.declarations[3].name == "TimesTable.subscript(n: Int) -> Planet")
        XCTAssert(source.declarations[4].name == "TimesTable.subscript<Item>(n: Int) -> Item")
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
            var value: String = "" {
                didSet { numberOfEdits += 1 }
            }
            var max: Int {
                get { 0 }
                set { }
            }
        }
        """)
        XCTAssert(source.declarations.count == 9)
        XCTAssert(source.declarations[0].name == "name")
        XCTAssert(source.declarations[1].name == "id")
        XCTAssert(source.declarations[2].name == "a,b,c")
        XCTAssert(source.declarations[3].name == "volume")
        XCTAssert(source.declarations[4].name == "importer")
        XCTAssert(source.declarations[5].name == "Math")
        XCTAssert(source.declarations[6].name == "Math.mathFunction")
        XCTAssert(source.declarations[7].name == "Math.value")
        XCTAssert(source.declarations[8].name == "Math.max")
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
        XCTAssert(source.declarations[0].name == "CompassPoint")
        XCTAssert(source.declarations[1].name == "CompassPoint.north,south")
        XCTAssert(source.declarations[2].name == "CompassPoint.east")
        XCTAssert(source.declarations[3].name == "CompassPoint.west")
        XCTAssert(source.declarations[4].name == "CompassPoint.upc(Int, Int, Int, Int)")
        XCTAssert(source.declarations[5].name == "Planet<Item>")
    }
    
    func test_precedencegroup_operator() throws {
        let source = try Source(source: """
        precedencegroup ForwardPipe {
            associativity: left
        }
        infix operator => : ForwardPipe
        """)
        XCTAssert(source.declarations.count == 2)
        XCTAssert(source.declarations[0].name == "precedencegroup ForwardPipe")
        XCTAssert(source.declarations[1].name == "operator =>")
    }
    
    func test_nested_types() throws {
        let source = try Source(source: """
        struct BlackjackCard {

            // nested Suit enumeration
            enum Suit: Character {
                case spades = "♠", hearts = "♡", diamonds = "♢", clubs = "♣"
            }

            // nested Rank enumeration
            enum Rank: Int {
                case two = 2, three, four, five, six, seven, eight, nine, ten
                case jack, queen, king, ace
                struct Values {
                    let first: Int, second: Int?
                }
                var values: Values {
                    switch self {
                    case .ace:
                        return Values(first: 1, second: 11)
                    case .jack, .queen, .king:
                        return Values(first: 10, second: nil)
                    default:
                        return Values(first: self.rawValue, second: nil)
                    }
                }
            }

            // BlackjackCard properties and methods
            let rank: Rank, suit: Suit
            var description: String {
                var output = "suit is (suit.rawValue),"
                output += " value is (rank.values.first)"
                if let second = rank.values.second {
                    output += " or (second)"
                }
                return output
            }
        }
        """)
        XCTAssert(source.declarations.count == 11)
        XCTAssert(source.declarations[0].name == "BlackjackCard")
        XCTAssert(source.declarations[1].name == "BlackjackCard.Suit")
        XCTAssert(source.declarations[2].name == "BlackjackCard.Suit.spades,hearts,diamonds,clubs")
        XCTAssert(source.declarations[3].name == "BlackjackCard.Rank")
        XCTAssert(source.declarations[4].name == "BlackjackCard.Rank.two,three,four,five,six,seven,eight,nine,ten")
        XCTAssert(source.declarations[5].name == "BlackjackCard.Rank.jack,queen,king,ace")
        XCTAssert(source.declarations[6].name == "BlackjackCard.Rank.Values")
        XCTAssert(source.declarations[7].name == "BlackjackCard.Rank.Values.first,second")
        XCTAssert(source.declarations[8].name == "BlackjackCard.Rank.values")
        XCTAssert(source.declarations[9].name == "BlackjackCard.rank,suit")
        XCTAssert(source.declarations[10].name == "BlackjackCard.description")
    }
    
    func test_access_level() throws {
        let source = try Source(source: """
        open class A {}
        public class B {}
        internal class C {}
        class D {}
        fileprivate class E {}
        private class F {}
        
        public struct TrackedString {
            public internal(set) var a = 0
            fileprivate(set) var b = 0
            fileprivate private(set) var c = 0
        }
        """)
        XCTAssert(source.declarations.count == 10)
        XCTAssert(source.declarations[0].accessLevel == .open)
        XCTAssert(source.declarations[1].accessLevel == .public)
        XCTAssert(source.declarations[2].accessLevel == .internal)
        XCTAssert(source.declarations[3].accessLevel == .internal)
        XCTAssert(source.declarations[4].accessLevel == .fileprivate)
        XCTAssert(source.declarations[5].accessLevel == .private)
        
        XCTAssert(source.declarations[6].accessLevel == .public)
        XCTAssert(source.declarations[7].accessLevel == .public)
        XCTAssert(source.declarations[8].accessLevel == .internal)
        XCTAssert(source.declarations[9].accessLevel == .fileprivate)
    }
}

final class DocumentationTests: XCTestCase {
    
    func test_comments() throws {
        let source = try Source(source: """
        // A developer line comment
        /*
        A developer block comment
        */
        
        /// A documentation line comment
        /**
        A documentation block comment
        */
        mutating public func eat(_ food: Food, quantity: Int) throws -> Int { return 0 }
        """)
        XCTAssert(source.declarations.count == 1)
        XCTAssert(source.declarations[0].comments.count == 4)
        XCTAssert(source.declarations[0].comments[0].kind == .line)
        XCTAssert(source.declarations[0].comments[1].kind == .block)
        XCTAssert(source.declarations[0].comments[2].kind == .docLine)
        XCTAssert(source.declarations[0].comments[3].kind == .docBlock)
    }
}

final class FileTests: XCTestCase {
    
    let fileURL = Bundle.module.url(forResource: "Rect", withExtension: "swift", subdirectory: "Resources/Rect")!
    
    func test_file() throws {
        let source = try Source(fileURL: fileURL, minAccessLevel: .private)
        XCTAssert(source.declarations.count == 4)
    }
    
    func test_scan_notfound() throws {
        XCTAssertThrowsError(try Coverage(path: "NotFound")) { error in
            XCTAssert(error.localizedDescription == "Path not found.")
        }
    }
    
    func test_report() throws {
        let coverage = try Coverage(path: fileURL.path, minAccessLevel: .public)
        let report = try coverage.report()
        
        XCTAssert(report.totalCount == 4)
        XCTAssert(report.totalUndocumentedCount == 2)
        XCTAssert(report.sources.count == 1)
        
        try coverage.printStatistics()
    }
    
    func test_warnings() throws {
        let coverage = try Coverage(path: fileURL.path, minAccessLevel: .public)
        try coverage.printWarnings()
    }
}

extension Process {
    
    func run(_ executableURL: URL, arguments: [String]? = nil) throws -> String {
        self.executableURL = executableURL
        self.arguments = arguments
        
        let pipe = Pipe()
        standardOutput = pipe
        standardError = pipe
        
        try run()
        waitUntilExit()
        
        guard terminationStatus == EXIT_SUCCESS else {
            let error = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
            throw (error?.trimmingCharacters(in: .newlines) ?? "")
        }
        
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        return output?.trimmingCharacters(in: .newlines) ?? ""
    }
}

final class ToolTests: XCTestCase {
    
    lazy var swiftDocCoverageURL: URL = {
        Bundle(for: Self.self).bundleURL.deletingLastPathComponent().appendingPathComponent("swift-doc-coverage")
    }()
    
    let fileURL = Bundle.module.url(forResource: "Rect", withExtension: "swift", subdirectory: "Resources/Rect")!
    
    func test_not_found() {
        let process = Process()
        do {
            let output = try process.run(swiftDocCoverageURL, arguments: ["NotFound"])
            XCTFail(output)
        }
        catch {
            XCTAssert(error.localizedDescription == "Error: Path not found.")
        }
        XCTAssert(process.terminationStatus == EXIT_FAILURE)
    }
    
    func test_output() throws {
        let process = Process()
        let output = try process.run(swiftDocCoverageURL, arguments: [fileURL.path])
        
        XCTAssert(process.terminationStatus == EXIT_SUCCESS)
        XCTAssert(output.contains("Total: 50%"))
    }
    
    func test_warninigs() throws {
        let process = Process()
        let output = try process.run(swiftDocCoverageURL, arguments: [fileURL.path, "--report", "warnings"])
        XCTAssert(process.terminationStatus == EXIT_SUCCESS)
        XCTAssert(output.contains("warning: No documentation."))
    }
    
    func test_json() throws {
        let process = Process()
        let output = try process.run(swiftDocCoverageURL, arguments: [fileURL.path, "--report", "json"])
        XCTAssert(process.terminationStatus == EXIT_SUCCESS)
        
        if let data = output.data(using: .utf8),
           let json = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
            XCTAssert(json["sources"] != nil)
        }
        else {
            XCTFail()
        }
    }
    
    func temporaryDirectory() throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    
    func test_file_output() throws {
        let tempDir = try temporaryDirectory()
        let outputFileURL = tempDir.appendingPathComponent("report.txt")
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let process = Process()
        let output = try process.run(swiftDocCoverageURL, arguments: [fileURL.path, "--output", outputFileURL.path])
        XCTAssert(process.terminationStatus == EXIT_SUCCESS)
        XCTAssert(output.isEmpty)
        
        let text = try String(contentsOf: outputFileURL)
        XCTAssert(text.contains("Total: 50%"))
    }
}
