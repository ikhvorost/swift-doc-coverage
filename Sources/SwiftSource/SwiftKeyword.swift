//  SwiftKeyword.swift
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

/// Swift declaration keyword.
public enum SwiftKeyword: String, Codable {
  /// `actor`
  case actor
  /// `associatedtype`
  case `associatedtype`
  /// Enum `case`
  case `case`
  /// `class`
  case `class`
  /// `enum`
  case `enum`
  /// `extension`
  case `extension`
  /// `func`
  case `func`
  // case `import`
  /// `init`
  case `init`
  /// Const variable `let`
  case `let`
  /// `macro`
  case macro
  /// `operator`
  case `operator`
  /// `precedencegroup`
  case `precedencegroup`
  /// `protocol`
  case `protocol`
  /// `struct`
  case `struct`
  /// `subscript`
  case `subscript`
  /// `typealias`
  case `typealias`
  /// Variable `var`
  case `var`
}
