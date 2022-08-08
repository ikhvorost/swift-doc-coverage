//  scan.swift
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


enum ScanError: String, Error {
    case fileNotFound = "File not found."
}

func scan(path: String, suffix: String = ".swift") throws -> [URL]  {
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
        throw ScanError.fileNotFound
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
                      name.hasSuffix(suffix)
                else {
                    continue
                }
                
                urls.append(fileURL)
            }
        }
        return urls
    }
    else {
        guard path.hasSuffix(suffix) else {
            throw ScanError.fileNotFound
        }
        let url = URL(fileURLWithPath: path)
        return [url]
    }
}
