//  DeclComment.swift
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


struct DeclComment {
  let piece: TriviaPiece
  
  var text: String {
    switch piece {
      case .lineComment(let text): return text
      case .blockComment(let text): return text
      case .docLineComment(let text): return text
      case .docBlockComment(let text): return text
      default: return ""
    }
  }
  
  var isDoc: Bool {
    switch piece {
      case .docLineComment:
        fallthrough
      case .docBlockComment:
        return true
      default:
        return true
    }
  }
  
  init(piece: TriviaPiece) {
    self.piece = piece
  }
}

struct DeclComments {
  private let pieces: [DeclComment]
  
  var count: Int { pieces.count }
  
  var documented: Bool {
    pieces.first { $0.isDoc } != nil
  }
  
  subscript(index: Int) -> DeclComment { pieces[index] }
  
  init(trivia: Trivia) {
    pieces = trivia.compactMap {
      switch $0 {
        case .lineComment:
          fallthrough
        case .blockComment:
          fallthrough
        case .docLineComment:
          fallthrough
        case .docBlockComment:
          return DeclComment(piece: $0)
        default:
          return nil
      }
    }
  }
}
