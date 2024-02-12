//  DeclKeyword.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 11.02.2024.
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


enum DeclKeyword: String {
  case actor
  case `associatedtype`
  case `case`
  case `class`
  //case `deinit`
  case `enum`
  case `extension`
  case `func`
  //case `import`
  case `init`
  case `let`
  case macro
  case `operator`
  case `precedencegroup`
  case `protocol`
  case `struct`
  case `subscript`
  case `typealias`
  case `var`
  //case `inout`
  //case pound
  
  init?(token: TokenSyntax) {
    guard case .keyword(let keyword) = token.tokenKind else {
      return nil
    }
    
    switch keyword {
      case .actor: self = .actor
      case .associatedtype: self = .associatedtype
      case .case: self = .case
      case .class: self = .class
      //case .deinit:
      case .enum: self = .enum
      case .extension: self = .extension
      case .func: self = .func
      //case .import:
      case .`init`: self = .`init`
      case .let: self = .let
      case .macro: self = .macro
      //case .operator:
      case .precedencegroup: self = .precedencegroup
      case .protocol: self = .protocol
      case .struct: self = .struct
      case .subscript: self = .subscript
      case .typealias: self = .typealias
      case .var: self = .var
      //case .inout
      //case .pound
      default: return nil
    }
  }
}
