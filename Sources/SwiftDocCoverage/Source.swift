//  Source.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 08.08.2022.
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
import SwiftParser


public struct Source {
  public let url: URL?
  public let source: String
  
  // https://oleb.net/blog/2015/12/lazy-properties-in-structs-swift/
  public var declarations: [Declaration] {
    Lazy.var {
      let sourceFile = Parser.parse(source: source)
      let converter = SourceLocationConverter(fileName: "", tree: sourceFile)
      let visitor = Visitor(sourceFile: sourceFile, converter: converter)
      return visitor.declarations
    }
  }
  
  public init(source: String) {
    self.url = nil
    self.source = source
  }
  
  public init(url: URL) throws {
    self.url = url
    self.source = try String(contentsOf: url)
  }
}
