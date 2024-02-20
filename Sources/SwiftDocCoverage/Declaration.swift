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

import SwiftSyntax


@resultBuilder
fileprivate struct StringBuilder {
  static func buildBlock(_ parts: String...) -> String {
    parts.joined()
  }
  
  static func buildOptional(_ component: String?) -> String {
    component ?? ""
  }
}

public class Declaration {
  private let decl: DeclProtocol
  private let context: [DeclProtocol]
  
  public let line: Int
  public let column: Int
  
  public var keyword: Keyword { decl.keyword }
  
  public private(set) lazy var accessLevel: AccessLevel = { decl.accessLevel }()
  public private(set) lazy var comments: [Comment] = { decl.comments }()
  public private(set) lazy var name: String = { buildName() }()

  @StringBuilder
  private func buildName() -> String {
    if decl.keyword != .`init`, decl.keyword != .subscript {
      decl.keyword.rawValue
      " "
    }
    
    if context.count > 0 {
      context.map { $0.name.trimmedDescription }.joined(separator: ".")
      "."
    }
    
    decl.name.trimmedDescription
    decl.genericParameterClause?.trimmedDescription ?? ""
    decl.inheritanceClause?.trimmedDescription ?? ""
    decl.funcSignature?.trimmedDescription ?? ""
    
    if let genericWhere = decl.genericWhereClause?.trimmedDescription {
      " "
      genericWhere
    }
  }
  
  init(decl: DeclProtocol, context: [DeclProtocol], location: SourceLocation) {
    self.decl = decl
    self.context = context
    self.line = location.line
    self.column = location.column
  }
}
