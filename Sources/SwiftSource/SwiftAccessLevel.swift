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


public enum SwiftAccessLevel: Int {
  case `open`
  case `public`
  case `internal`
  case `fileprivate`
  case `private`
  
  init?(token: TokenSyntax) {
    guard case .keyword(let keyword) = token.tokenKind else {
      return nil
    }
    
    switch keyword {
      case .open: self = .open
      case .public: self = .public
      case .internal: self = .internal
      case .fileprivate: self = .fileprivate
      case .private: self = .private
      default: return nil
    }
  }
  
  init(modifiers: DeclModifierListSyntax) {
    for modifier in modifiers {
      // Skip private(set) etc.
      guard modifier.detail == nil else {
        continue
      }
      
      if let accessLevel = SwiftAccessLevel(token: modifier.name) {
        self = accessLevel
        return
      }
    }
    self = .internal
  }
}
