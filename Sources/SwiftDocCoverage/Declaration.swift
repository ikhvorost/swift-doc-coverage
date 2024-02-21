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

public struct Declaration {
  public let comments: [Comment]
  public let accessLevel: AccessLevel
  public var keyword: Keyword
  public let name: String
  public let line: Int
  public let column: Int

  @StringBuilder
  private static func buildName(decl: DeclProtocol, path: String?) -> String {
    if decl.keyword != .`init`, decl.keyword != .subscript {
      decl.keyword.rawValue
      " "
    }
    
    if let path = path {
      path
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
  
  init(decl: DeclProtocol, path: String?, location: SourceLocation) {
    self.comments = decl.comments
    self.accessLevel = decl.accessLevel
    self.keyword = decl.keyword
    self.name = Self.buildName(decl: decl, path: path)
    self.line = location.line
    self.column = location.column
  }
}
