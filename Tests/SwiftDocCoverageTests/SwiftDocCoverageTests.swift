import XCTest
//import class Foundation.Bundle
@testable import SwiftDocCoverage

import SwiftSyntax
import SwiftSyntaxParser


/// String errors
extension String : LocalizedError {
    public var errorDescription: String? { return self }
}


final class SwiftDocCoverageTests: XCTestCase {
    
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
        let sourceFile = try SourceFile(fileURL: userFileURL)
        print(sourceFile.declarations[0].id)
    }
}
