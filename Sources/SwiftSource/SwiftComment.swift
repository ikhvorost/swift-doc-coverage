//  SwiftComment.swift
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

/// Swift declaration comment.
public struct SwiftComment: Codable {
  /// Text of this comment.
  public let text: String
  /// Returns `true` if this comment is documentation (starting with '///' or '/**').
  public var isDoc: Bool
  
  init?(piece: TriviaPiece) {
    switch piece {
      case .lineComment(let value):
        text = value
          .replacingOccurrences(of: "//", with: "")
          .trimmingCharacters(in: .whitespaces)
        isDoc = false
        
      case .blockComment(let value):
        text = value
          .replacingOccurrences(of: "/*", with: "")
          .replacingOccurrences(of: "*/", with: "")
          .trimmingCharacters(in: .whitespaces)
        isDoc = false
        
      case .docLineComment(let value):
        text = value
          .replacingOccurrences(of: "///", with: "")
          .trimmingCharacters(in: .whitespaces)
        isDoc = !text.isEmpty
        
      case .docBlockComment(let value):
        text = value
          .replacingOccurrences(of: "/**", with: "")
          .replacingOccurrences(of: "*/", with: "")
          .trimmingCharacters(in: .whitespaces)
        isDoc = !text.isEmpty
        
      default:
        return nil
    }
  }
}
