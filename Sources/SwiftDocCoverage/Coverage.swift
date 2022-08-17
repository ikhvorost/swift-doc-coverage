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


/// Error
extension String : LocalizedError {
    public var errorDescription: String? { return self }
}

fileprivate func scan(path: String, extention: String) throws -> [URL]  {
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
        throw "File or directory not existed."
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
    let sources: [SourceFile]
    
    init(paths: [String]) throws {
        let urls = try paths.flatMap { try scan(path: $0, extention: ".swift") }
        guard urls.count > 0 else {
            throw "Swift files not found."
        }

        sources = try urls.map { try SourceFile(fileURL: $0) }
    }
    
    init(path: String) throws {
        try self.init(paths: [path])
    }
    
    func reportUndocumented(accessLevel: AccessLevel) {
        var totalCount = 0
        var totalUndocumented = 0
        
        for source in sources {
            let path = source.fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")
            let fileName = NSString(string: path).lastPathComponent
            
            var count = 0
            var undocumented = [String]()
            for declaration in source.declarations {
                if declaration.accessLevel.rawValue <= accessLevel.rawValue {
                    if declaration.docComment == nil {
                        undocumented.append("<\(fileName):\(declaration.line)> \(declaration.name)")
                    }
                    count += 1
                }
            }
            
            totalCount += count
            totalUndocumented += undocumented.count
            
            // Skip
            guard count > 0 else {
                continue
            }
            
            let persent = (count - undocumented.count) * 100 / count
            print("\(path) - \(persent)%")
            
            if undocumented.count > 0 {
                print("Undocumented:")
                print(undocumented.joined(separator: "\n"), "\n")
                //print("\n")
            }
        }
        
        let total = totalUndocumented > 0 && totalCount > 0
            ? (totalCount - totalUndocumented) * 100 / totalCount
            : 100
        print("Total - \(total)%")
    }
}
