//  SwiftSource.swift
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


/// Swift source
public struct SwiftSource: Codable {
  /// Source URL
  public let url: URL?
  /// List of all parsed declarations
  public let declarations: [SwiftDeclaration]
  
  private init(url: URL?, source: String) {
    self.url = url
    let visitor = Visitor(source: source)
    self.declarations = visitor.declarations
  }
  
  /// Create from a specified swift code.
  public init(source: String) {
    self.init(url: nil, source: source)
  }
  
  /// Create from a specified URL.
  public init(url: URL) throws {
    let source = try String(contentsOf: url)
    self.init(url: url, source: source)
  }
  
  /// List of declarations with a specified access level
  public func declarations(accessLevel: SwiftAccessLevel) -> [SwiftDeclaration] {
    declarations.filter { $0.accessLevel.rawValue <= accessLevel.rawValue }
  }
}
