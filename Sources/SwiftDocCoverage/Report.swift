//  Report.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 08.09.2022.
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

struct DeclarationReport: Codable {
    let line: Int
    let column: Int
    let name: String
}

struct SourceReport: Codable {
    let path: String
    let totalCount: Int
    let undocumented: [DeclarationReport]
    
    var fileName: String {
        NSString(string: path).lastPathComponent
    }
    
    var coverage: Int {
        guard totalCount > 0 else {
            return 0
        }
        return (totalCount - undocumented.count) * 100 / totalCount
    }
}

struct CoverageReport: Codable {
    let sources: [SourceReport]
    
    var totalCount: Int {
        sources.reduce(0) { $0 + $1.totalCount }
    }
    
    var totalUndocumentedCount: Int {
        sources.reduce(0) { $0 + $1.undocumented.count }
    }
    
    var coverage: Int {
        guard totalCount > 0 else {
            return 0
        }
        return (totalCount - totalUndocumentedCount) * 100 / totalCount
    }
}
