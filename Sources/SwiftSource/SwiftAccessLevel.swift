//  SwiftAccessLevel.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 11.02.2022.
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

/// Swift declaration access level.
public enum SwiftAccessLevel: Int, Codable {
  /// Classes and methods marked as open can be subclassed and overridden respectively out of their defining module.
  case `open`
  /// Accessible from everywhere.
  case `public`
  /// Accessible only within the defined module (default)
  case `internal`
  /// Accessible only within the current swift file.
  case `fileprivate`
  /// Accessible only within the defined class or struct.
  case `private`
  
 init(modifiers: DeclModifierListSyntax) {
    for modifier in modifiers {
      guard modifier.detail == nil, // Skip private(set) etc.
              case .keyword(let keyword) = modifier.name.tokenKind
      else {
        continue
      }
      
      switch keyword {
        case .open: 
          self = .open
          return
        case .public: 
          self = .public
          return
        case .internal:
          self = .internal
          return
        case .fileprivate:
          self = .fileprivate
          return
        case .private:
          self = .private
          return
        default:
          break
      }
    }
    self = .internal
  }
}
