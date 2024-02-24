import XCTest
/*@testable */import SwiftSource

extension String : LocalizedError {
  public var errorDescription: String? { self }
}

func tempDirectory() -> URL {
  let url = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
  try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  return url
}

final class DeclarationTests: XCTestCase {
  
 func test_typealias() {
    let code = 
    """
    typealias SSN = Int
    class Audio {
      typealias AudioSample = UInt16
    }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 3)
    XCTAssert(source.declarations[0].name == "typealias SSN")
    XCTAssert(source.declarations[1].name == "class Audio")
    XCTAssert(source.declarations[2].name == "typealias Audio.AudioSample")
  }
  
  func test_associatedtype() {
    let code =
    """
    protocol Container {
      associatedtype Item
      associatedtype Element: Equatable
      associatedtype Suffix: SuffixableContainer where Suffix.Item == Item
    }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 4)
    XCTAssert(source.declarations[0].name == "protocol Container")
    XCTAssert(source.declarations[1].name == "associatedtype Container.Item")
    XCTAssert(source.declarations[2].name == "associatedtype Container.Element: Equatable")
    XCTAssert(source.declarations[3].name == "associatedtype Container.Suffix: SuffixableContainer where Suffix.Item == Item")
  }
  
  func test_if_endif() {
    let code =
    """
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
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 5)
    XCTAssert(source.declarations[0].name == "class A")
    XCTAssert(source.declarations[1].name == "class B")
    XCTAssert(source.declarations[2].name == "class C")
    XCTAssert(source.declarations[3].name == "class D")
    XCTAssert(source.declarations[4].name == "class E")
  }
  
  func test_class_actor() {
    let code =
    """
    class Vehicle {}
    class Bicycle: Vehicle {}
    class Stack<Element> {}
    class Stack<Element>: Base {}
    actor UserStorage {}
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 5)
    XCTAssert(source.declarations[0].name == "class Vehicle")
    XCTAssert(source.declarations[1].name == "class Bicycle: Vehicle")
    XCTAssert(source.declarations[2].name == "class Stack<Element>")
    XCTAssert(source.declarations[3].name == "class Stack<Element>: Base")
    XCTAssert(source.declarations[4].name == "actor UserStorage")
  }
  
  func test_struct() {
    let code =
    """
    struct Book {}
    struct Person: FullyNamed {}
    struct Stack<Element> {}
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 3)
    XCTAssert(source.declarations[0].name == "struct Book")
    XCTAssert(source.declarations[1].name == "struct Person: FullyNamed")
    XCTAssert(source.declarations[2].name == "struct Stack<Element>")
  }
  
  func test_protocol() {
    let code =
    """
    protocol Container {}
    protocol InheritingProtocol: SomeProtocol, AnotherProtocol {}
    protocol SomeClassOnlyProtocol: AnyObject, SomeInheritedProtocol {}
    @objc protocol CounterDataSource {}
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 4)
    XCTAssert(source.declarations[0].name == "protocol Container")
    XCTAssert(source.declarations[1].name == "protocol InheritingProtocol: SomeProtocol, AnotherProtocol")
    XCTAssert(source.declarations[2].name == "protocol SomeClassOnlyProtocol: AnyObject, SomeInheritedProtocol")
    XCTAssert(source.declarations[3].name == "protocol CounterDataSource")
  }
  
  func test_extention() {
    let code =
    """
    extension Container {}
    extension SomeType: SomeProtocol, AnotherProtocol {}
    extension Array: TextRepresentable where Element: TextRepresentable {}
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 3)
    XCTAssert(source.declarations[0].name == "extension Container")
    XCTAssert(source.declarations[1].name == "extension SomeType: SomeProtocol, AnotherProtocol")
    XCTAssert(source.declarations[2].name == "extension Array: TextRepresentable where Element: TextRepresentable")
  }
  
  func test_function() {
    let code =
    """
    func greet(person: String) -> String { return person; }
    func someFunction(argumentLabel parameterName: Int) {}
    func arithmeticMean(_ numbers: Double...) -> Double {}
    func swapTwoValues<T>(_ a: inout T, _ b: inout T) {}
    enum CompassPoint {
      mutating func turnNorth() {}
      static func + (left: Vector2D, right: Vector2D) -> Vector2D {}
    }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 7)
    XCTAssert(source.declarations[0].name == "func greet(person: String) -> String")
    XCTAssert(source.declarations[1].name == "func someFunction(argumentLabel parameterName: Int)")
    XCTAssert(source.declarations[2].name == "func arithmeticMean(_ numbers: Double...) -> Double")
    XCTAssert(source.declarations[3].name == "func swapTwoValues<T>(_ a: inout T, _ b: inout T)")
    XCTAssert(source.declarations[4].name == "enum CompassPoint")
    XCTAssert(source.declarations[5].name == "func CompassPoint.turnNorth()")
    XCTAssert(source.declarations[6].name == "func CompassPoint.+(left: Vector2D, right: Vector2D) -> Vector2D")
  }
  
  func test_initializer() {
    let code =
    """
    struct Color {
      init() {}
      override init() {}
      init(fromFahrenheit fahrenheit: Double) {}
      init(_ celsius: Double) {}
      init?(species: String) {}
      init<Item>(item: Item) {}
      init<Item>(item: Item) where Element: TextRepresentable {}
    }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 8)
    XCTAssert(source.declarations[0].name == "struct Color")
    XCTAssert(source.declarations[1].name == "Color.init()")
    XCTAssert(source.declarations[2].name == "Color.init()")
    XCTAssert(source.declarations[3].name == "Color.init(fromFahrenheit fahrenheit: Double)")
    XCTAssert(source.declarations[4].name == "Color.init(_ celsius: Double)")
    XCTAssert(source.declarations[5].name == "Color.init?(species: String)")
    XCTAssert(source.declarations[6].name == "Color.init<Item>(item: Item)")
    XCTAssert(source.declarations[7].name == "Color.init<Item>(item: Item) where Element: TextRepresentable")
  }
  
  func test_subscript() {
    let code =
    """
    struct TimesTable {
      subscript(index: Int) -> Int { return multiplier * index }
      subscript(row: Int, column: Int) -> Double {}
      static subscript(n: Int) -> Planet {}
      subscript<Item>(n: Int) -> Item {}
    }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 5)
    XCTAssert(source.declarations[0].name == "struct TimesTable")
    XCTAssert(source.declarations[1].name == "TimesTable.subscript(index: Int) -> Int")
    XCTAssert(source.declarations[2].name == "TimesTable.subscript(row: Int, column: Int) -> Double")
    XCTAssert(source.declarations[3].name == "TimesTable.subscript(n: Int) -> Planet")
    XCTAssert(source.declarations[4].name == "TimesTable.subscript<Item>(n: Int) -> Item")
  }
  
  func test_variable() {
    let code =
    """
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
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 9)
    XCTAssert(source.declarations[0].name == "let name")
    XCTAssert(source.declarations[1].name == "let id")
    XCTAssert(source.declarations[2].name == "let a,b,c")
    XCTAssert(source.declarations[3].name == "var volume")
    XCTAssert(source.declarations[4].name == "var importer")
    XCTAssert(source.declarations[5].name == "class Math")
    XCTAssert(source.declarations[6].name == "var Math.mathFunction")
    XCTAssert(source.declarations[7].name == "var Math.value")
    XCTAssert(source.declarations[8].name == "var Math.max")
  }
  
  func test_enum() {
    let code =
    """
    enum CompassPoint {
      case north, south
      case east
      case west
      case upc(Int, Int, Int, Int)
    }
    enum Planet<Item> {}
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 6)
    XCTAssert(source.declarations[0].name == "enum CompassPoint")
    XCTAssert(source.declarations[1].name == "case CompassPoint.north,south")
    XCTAssert(source.declarations[2].name == "case CompassPoint.east")
    XCTAssert(source.declarations[3].name == "case CompassPoint.west")
    XCTAssert(source.declarations[4].name == "case CompassPoint.upc(Int, Int, Int, Int)")
    XCTAssert(source.declarations[5].name == "enum Planet<Item>")
  }
  
  func test_precedencegroup_operator() {
    let code =
    """
    precedencegroup ForwardPipe {
      associativity: left
    }
    infix operator => : ForwardPipe
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 1)
    XCTAssert(source.declarations[0].name == "precedencegroup ForwardPipe")
    //XCTAssert(source.declarations[1].name == "operator =>")
  }
  
  func test_nested_types() {
    let code =
    """
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
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 11)
    XCTAssert(source.declarations[0].name == "struct BlackjackCard")
    XCTAssert(source.declarations[1].name == "enum BlackjackCard.Suit: Character")
    XCTAssert(source.declarations[2].name == "case BlackjackCard.Suit.spades,hearts,diamonds,clubs")
    XCTAssert(source.declarations[3].name == "enum BlackjackCard.Rank: Int")
    XCTAssert(source.declarations[4].name == "case BlackjackCard.Rank.two,three,four,five,six,seven,eight,nine,ten")
    XCTAssert(source.declarations[5].name == "case BlackjackCard.Rank.jack,queen,king,ace")
    XCTAssert(source.declarations[6].name == "struct BlackjackCard.Rank.Values")
    XCTAssert(source.declarations[7].name == "let BlackjackCard.Rank.Values.first,second")
    XCTAssert(source.declarations[8].name == "var BlackjackCard.Rank.values")
    XCTAssert(source.declarations[9].name == "let BlackjackCard.rank,suit")
    XCTAssert(source.declarations[10].name == "var BlackjackCard.description")
  }
  
  func test_access_level() {
    let code =
    """
    open class A {}
    public class B {}
    internal class C {}
    class D {}
    fileprivate class E {}
    private class F {}
    final class G {}
    
    public struct TrackedString {
      public private(set) var a = 0
      private(set) public var c = 0
      fileprivate(set) var b = 0
      static let shared = 10
    }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 12)
    XCTAssert(source.declarations[0].accessLevel == .open)
    XCTAssert(source.declarations[1].accessLevel == .public)
    XCTAssert(source.declarations[2].accessLevel == .internal)
    XCTAssert(source.declarations[3].accessLevel == .internal)
    XCTAssert(source.declarations[4].accessLevel == .fileprivate)
    XCTAssert(source.declarations[5].accessLevel == .private)
    XCTAssert(source.declarations[6].accessLevel == .internal)
    
    XCTAssert(source.declarations[7].accessLevel == .public)
    XCTAssert(source.declarations[8].accessLevel == .public)
    XCTAssert(source.declarations[9].accessLevel == .public)
    XCTAssert(source.declarations[10].accessLevel == .internal)
    XCTAssert(source.declarations[11].accessLevel == .internal)
  }
}

final class DocumentationTests: XCTestCase {
  
  func test_no_comments() {
    let code =
    """
    public func eat(_ food: Food, quantity: Int) throws -> Int { return 0 }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 1)
    XCTAssert(source.declarations[0].comments.count == 0)
  }
  
  func test_comments() {
    let code =
    """
    // A developer line comment
    /* A developer block comment */
    /// A documentation line comment
    /** A documentation block comment */
    mutating public func eat(_ food: Food, quantity: Int) throws -> Int { return 0 }
    """
    let source = SwiftSource(source: code)
    XCTAssert(source.declarations.count == 1)
    XCTAssert(source.declarations[0].comments.count == 4)
    XCTAssert(source.declarations[0].comments[0].text == "// A developer line comment")
    XCTAssert(source.declarations[0].comments[1].text == "/* A developer block comment */")
    XCTAssert(source.declarations[0].comments[2].text == "/// A documentation line comment")
    XCTAssert(source.declarations[0].comments[3].text == "/** A documentation block comment */")
  }
}

final class FileTests: XCTestCase {
  
  static let directoryURL = Bundle.module.url(forResource: "Resources", withExtension: nil, subdirectory: nil)!
  static let fileURL =  directoryURL.appendingPathComponent("Rect/Rect.swift")
  static let readmeURL =  directoryURL.appendingPathComponent("README.md")
  static let emptyDirURL =  directoryURL.appendingPathComponent("Empty")
  
  func test_file() throws {
    let source = try SwiftSource(url: Self.fileURL)
    XCTAssert(source.declarations.count == 4)
  }
  
  func test_not_found() throws {
//    XCTAssertThrowsError(try Coverage(paths: [Self.directoryURL.appendingPathComponent("NotFound").path])) { error in
//      XCTAssert(error.localizedDescription == "Path not found.")
//    }
  }
  
  func test_not_swift_file() throws {
//    XCTAssertThrowsError(try Coverage(paths: [Self.readmeURL.path])) { error in
//      XCTAssert(error.localizedDescription == "Not swift file.")
//    }
  }
  
  func test_no_declarations() throws {
//    let coverage = try Coverage(paths: [Self.fileURL.path], minAccessLevel: .open)
//    XCTAssertThrowsError(try coverage.report()) { error in
//      XCTAssert(error.localizedDescription == "Declarations not found.")
//    }
  }
  
  func test_report() throws {
//    let coverage = try Coverage(paths: [Self.fileURL.path])
//    let report = try coverage.report()
//    
//    XCTAssert(report.totalCount == 4)
//    XCTAssert(report.totalUndocumentedCount == 2)
//    XCTAssert(report.sources.count == 1)
//    
//    try coverage.reportStatistics()
  }
  
  func test_empty_directory() throws {
//    let tempDirectory = tempDirectory()
//    defer { try? FileManager.default.removeItem(at: tempDirectory) }
//    
//    XCTAssertThrowsError(try Coverage(paths: [tempDirectory.path])) { error in
//      XCTAssert(error.localizedDescription == "Swift files not found.")
//    }
  }
  
  func test_directory() throws {
//    let coverage = try Coverage(paths: [Self.directoryURL.path])
//    let report = try coverage.report()
//    
//    XCTAssert(report.totalCount == 4)
//    XCTAssert(report.totalUndocumentedCount == 2)
//    print(report.sources.count == 1)
  }
  
  func test_warnings() throws {
//    let coverage = try Coverage(paths: [Self.fileURL.path])
//    try coverage.reportWarnings()
  }
}

#if !os(watchOS)

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
    XCTAssert(output.contains("warning: No documentation for 'Rect.size'."))
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
  
  func test_file_output() throws {
    let tempDirectory = tempDirectory()
    let outputFileURL = tempDirectory.appendingPathComponent("report.txt")
    defer { try? FileManager.default.removeItem(at: tempDirectory) }
    
    let process = Process()
    let output = try process.run(swiftDocCoverageURL, arguments: [fileURL.path, "--output", outputFileURL.path])
    XCTAssert(process.terminationStatus == EXIT_SUCCESS)
    XCTAssert(output.isEmpty)
    
    let text = try String(contentsOf: outputFileURL)
    XCTAssert(text.contains("Total: 50%"))
  }
}

#endif
