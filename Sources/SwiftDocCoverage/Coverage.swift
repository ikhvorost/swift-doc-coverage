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
    public var errorDescription: String? { return self }
}

fileprivate extension URL {
    var fileName: String {
        NSString(string: absoluteString).lastPathComponent
    }
    
    var path: String {
        absoluteString.replacingOccurrences(of: "file://", with: "")
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
                      let isDirectory = resourceValues.isDirectory,
                      !isDirectory,
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

struct Coverage {
    let totalCount: Int
    let undocumentedCount: Int
    let sources: [Source]
    let output: Output
    
    init(paths: [String], minAccessLevel: AccessLevel = .private, output: Output) throws {
        let urls = try paths.flatMap { try scan(path: $0, extention: ".swift") }
        guard urls.count > 0 else {
            throw "Swift files not found."
        }

        sources = try urls.compactMap {
            let source = try Source(fileURL: $0, minAccessLevel: minAccessLevel)
            return source.declarations.count > 0
                ? source
                : nil
        }
        
        self.output = output
        
        totalCount = sources.reduce(0, { $0 + $1.declarations.count })
        undocumentedCount = sources.reduce(0, { $0 + $1.undocumented.count })
    }
    
    init(path: String, minAccessLevel: AccessLevel = .private, output: Output = TerminalOutput()) throws {
        try self.init(paths: [path], minAccessLevel: minAccessLevel, output: output)
    }
    
    func printStatistics() {
        for (i, source) in sources.enumerated() {
            assert(source.declarations.count > 0)
            assert(source.fileURL != nil)
            
            let sourceTotalCount = source.declarations.count
            output.write("\(i + 1)) \(source.fileURL!.path): \(source.coverage)% (\(sourceTotalCount - source.undocumented.count)/\(sourceTotalCount))")
            
            if source.undocumented.count > 0 {
                output.write("Undocumented:")
                
                source.undocumented.forEach {
                    output.write("<\(source.fileURL!.fileName):\($0.line):\($0.column)> \($0.name)")
                }
                
                output.write("\n", terminator: "")
            }
        }
        
        let total = undocumentedCount > 0 && totalCount > 0
            ? (totalCount - undocumentedCount) * 100 / totalCount
            : 100
        output.write("Total: \(total)% (\(totalCount - undocumentedCount)/\(totalCount))")
    }
    
    func printWarnings() {
        sources.forEach {
            let path = $0.fileURL!.path
            $0.undocumented.forEach {
                output.write("\(path):\($0.line):\($0.column): warning: No documentation.")
            }
        }
    }
}
