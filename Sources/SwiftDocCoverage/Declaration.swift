//  Declaration.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 09.08.2022.
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
import SwiftSyntax

fileprivate extension String {
    
    static let regexNewLine = try! NSRegularExpression(pattern: "\\n\\s+", options: [])
    
    func refine() -> String {
        let range = NSRange(startIndex..., in: self)
        return Self.regexNewLine.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: " ")
    }
 }


class Declaration {
    let decl: DeclProtocol
    let context: [DeclProtocol]
    let line: Int
    let column: Int
    
    lazy var accessLevel: AccessLevel = { decl.accessLevel }()
    
    lazy var comments: [Comment] = { decl.comments }()
    lazy var hasDoc: Bool = { comments.contains { $0.isDoc } }()
    
    lazy var name: String = {
        let name = decl.id.refine()
        let parent = context.map { $0.id }.joined(separator: ".")
        
        return parent.isEmpty
            ? name
            : "\(parent).\(name)"
    }()
    
    init(decl: DeclProtocol, context: [DeclProtocol], line: Int, column: Int) {
        self.decl = decl
        self.context = context
        self.line = line
        self.column = column
    }
}
