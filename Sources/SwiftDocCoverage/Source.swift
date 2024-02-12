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


fileprivate class Visitor: SyntaxVisitor {
  var declarations = [Declaration]()
  var context = [DeclProtocol]()
  let converter: SourceLocationConverter
  let minAccessLevel: AccessLevel
  
  init(sourceFile: SourceFileSyntax, converter: SourceLocationConverter, minAccessLevel: AccessLevel) {
    self.converter = converter
    self.minAccessLevel = minAccessLevel
    super.init(viewMode: .sourceAccurate)
    walk(sourceFile)
  }
  
  func append(decl: DeclProtocol) {
    guard decl.accessLevel.rawValue <= minAccessLevel.rawValue else {
      return
    }
    
    let startLocation = decl.startLocation(converter: converter, afterLeadingTrivia: true)
    let declaration = Declaration(decl: decl, context: context, location: startLocation)
    declarations.append(declaration)
  }
  
  // MARK: - SyntaxVisitor
  
  // UnknownDeclSyntax
  
  override func visit(_ node: TypeAliasDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  override func visit(_ node: AssociatedTypeDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  // IfConfigDeclSyntax
  // IfConfigClauseSyntax
  // PoundErrorDeclSyntax
  // PoundWarningDeclSyntax
  // PoundSourceLocationSyntax
  
  override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    context.append(node)
    return .visitChildren
  }
  
  override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    context.append(node)
    return .visitChildren
  }
  
  override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    context.append(node)
    return .visitChildren
  }
  
  override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    context.append(node)
    return .visitChildren
  }
  
  override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    context.append(node)
    return .visitChildren
  }
  
  override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  // DeinitializerDeclSyntax
  
  override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  // ImportDeclSyntax
  // AccessorDeclSyntax
  
  override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    context.append(node)
    return .visitChildren
  }
  
  override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  override func visit(_ node: MacroDeclSyntax) -> SyntaxVisitorContinueKind {
    append(decl: node)
    return .skipChildren
  }
  
  // MARK: -
  
  override func visitPost(_ node: ClassDeclSyntax) {
    let decl = context.popLast()
    assert(decl is ClassDeclSyntax)
  }
  
  override func visitPost(_ node: ActorDeclSyntax) {
    let decl = context.popLast()
    assert(decl is ActorDeclSyntax)
  }
  
  override func visitPost(_ node: EnumDeclSyntax) {
    let decl = context.popLast()
    assert(decl is EnumDeclSyntax)
  }
  
  override func visitPost(_ node: ExtensionDeclSyntax) {
    let decl = context.popLast()
    assert(decl is ExtensionDeclSyntax)
  }
  
  override func visitPost(_ node: ProtocolDeclSyntax) {
    let decl = context.popLast()
    assert(decl is ProtocolDeclSyntax)
  }
  
  override func visitPost(_ node: StructDeclSyntax) {
    let decl = context.popLast()
    assert(decl is StructDeclSyntax)
  }
}

struct Source {
  let declarations: [Declaration]
  
  var undocumented: [Declaration] {
    declarations.filter { $0.comments.documented == false }
  }
  
  private init(_ sourceFile: SourceFileSyntax, minAccessLevel: AccessLevel) throws {
    let converter = SourceLocationConverter(fileName: "", tree: sourceFile)
    let visitor = Visitor(sourceFile: sourceFile, converter: converter, minAccessLevel: minAccessLevel)
    declarations = visitor.declarations
  }
  
  init(source: String, minAccessLevel: AccessLevel = .private) throws {
    let sourceFile = Parser.parse(source: source)
    try self.init(sourceFile, minAccessLevel: minAccessLevel)
  }
  
  init(fileURL: URL, minAccessLevel: AccessLevel = .private) throws {
    let source = try String(contentsOf: fileURL)
    let sourceFile = Parser.parse(source: source)
    try self.init(sourceFile, minAccessLevel: minAccessLevel)
  }
}
