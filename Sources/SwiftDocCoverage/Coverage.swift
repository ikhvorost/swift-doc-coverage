//  Coverage.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 05.08.2022.
//  Copyright © 2022 Iurii Khvorost. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation


extension String : LocalizedError {
    public var errorDescription: String? { self }
}

fileprivate extension URL {
    var fileName: String {
        NSString(string: path).lastPathComponent
    }
}

fileprivate func scan(path: String, extention: String) throws -> [URL]  {
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
        throw "Path not found."
    }
    
    if isDirectory.boolValue {
        var urls = [URL]()
        let url = URL(fileURLWithPath: path)
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey]) {
            for case let fileURL as URL in enumerator {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                      let isDirectory = resourceValues.isDirectory, !isDirectory,
                      let name = resourceValues.name,
                      name.hasSuffix(extention)
                else {
                    continue
                }
                
                urls.append(fileURL)
            }
        }
        return urls
    }
    else {
        guard path.hasSuffix(extention) else {
            throw "Not swift file."
        }
        let url = URL(fileURLWithPath: path)
        return [url]
    }
}

public struct Coverage {
    let urls: [URL]
    let minAccessLevel: AccessLevel
    let output: Output
    
    public init(paths: [String], minAccessLevel: AccessLevel = .private, output: Output) throws {
        self.urls = try paths.flatMap { try scan(path: $0, extention: ".swift") }
        guard urls.count > 0 else {
            throw "Swift files not found."
        }
        self.minAccessLevel = minAccessLevel
        self.output = output
    }
    
    init(path: String, minAccessLevel: AccessLevel = .private, output: Output = TerminalOutput()) throws {
        try self.init(paths: [path], minAccessLevel: minAccessLevel, output: output)
    }
    
    @discardableResult
    func report(_ body: ((SourceReport) -> Void)? = nil) throws -> CoverageReport {
        var sources = [SourceReport]()
        
        try urls.forEach { url in
            let source = try Source(fileURL: url, minAccessLevel: minAccessLevel)
            guard source.declarations.count > 0 else {
                return
            }
            
            let undocumented = source.undocumented.map { DeclarationReport(line: $0.line, column: $0.line, name: $0.name) }
            let sourceReport = SourceReport(path: url.path,
                                            totalCount: source.declarations.count,
                                            undocumented: undocumented)
            sources.append(sourceReport)
            
            body?(sourceReport)
        }
        
        return CoverageReport(sources: sources)
    }
    
    public func printStatistics() throws {
        var i = 1
        let report = try report() { source in
            output.write("\(i)) \(source.path): \(source.coverage)% [\(source.totalCount - source.undocumented.count)/\(source.totalCount)]")
            
            if source.undocumented.count > 0 {
                output.write("Undocumented:")
                
                source.undocumented.forEach {
                    output.write("<\(source.fileName):\($0.line):\($0.column)> \($0.name)")
                }
                
                output.write("\n", terminator: "")
            }
            
            i += 1
        }
        output.write("Total: \(report.coverage)% [\(report.totalCount - report.totalUndocumentedCount)/\(report.totalCount)]")
    }
    
    public func printWarnings() throws {
        try report { source in
            source.undocumented.forEach {
                output.write("\(source.path):\($0.line):\($0.column): warning: No documentation.")
            }
        }
    }
    
    public func printJson() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let report = try report()
        let data = try encoder.encode(report)
        let json = String(data: data, encoding: .utf8)!
        
        output.write(json)
    }
}
