//  DeclProtocol.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 07.08.2022.
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


protocol DeclProtocol: SyntaxProtocol {
  
  // var attributes: AttributeListSyntax
  var modifiers: DeclModifierListSyntax { get }
  var keyword: DeclKeyword { get }
  var name: TokenSyntax { get }
  
  var genericParameterClause: GenericParameterClauseSyntax? { get }
  var inheritanceClause: InheritanceClauseSyntax? { get }
  var funcSignature: FunctionSignatureSyntax? { get }
  var genericWhereClause: GenericWhereClauseSyntax? { get }
}

extension DeclProtocol {
  var genericParameterClause: GenericParameterClauseSyntax? { nil }
  var inheritanceClause: InheritanceClauseSyntax? { nil }
  var funcSignature: FunctionSignatureSyntax? { nil }
  var genericWhereClause: GenericWhereClauseSyntax? { nil }
  
  var comments: DeclComments { DeclComments(trivia: leadingTrivia) }
  var accessLevel: AccessLevel { AccessLevel(modifiers: modifiers) }
}

// MARK: -

extension TypeAliasDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .typealias }
}

extension AssociatedTypeDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .associatedtype }
}

extension ClassDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .class }
}

extension ActorDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .actor }
}

extension StructDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .struct }
}

extension ProtocolDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .protocol }
}

extension ExtensionDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .extension }
  var name: TokenSyntax { TokenSyntax(.identifier(extendedType.trimmedDescription), presence: .present)}
}

extension FunctionDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .func }
  var funcSignature: FunctionSignatureSyntax? { signature }
}

extension InitializerDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .`init` }
  
  var name: TokenSyntax {
    let optionalMark = optionalMark?.trimmedDescription ?? ""
    return TokenSyntax(.identifier("init\(optionalMark)"), presence: .present)
  }
  
  var funcSignature: FunctionSignatureSyntax? { signature }
}

extension SubscriptDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .subscript }
  
  var name: TokenSyntax {
    TokenSyntax(.identifier("subscript"), presence: .present)
  }
  
  var funcSignature: FunctionSignatureSyntax? {
    FunctionSignatureSyntax(parameterClause: parameterClause, effectSpecifiers: nil, returnClause: returnClause)
  }
}

extension VariableDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { DeclKeyword(token: bindingSpecifier)! }
  
  var name: TokenSyntax {
    let name = bindings.map { $0.pattern.trimmedDescription }.joined(separator: ",")
    return TokenSyntax(.identifier(name), presence: .present)
  }
}

extension EnumDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .enum }
}

extension EnumCaseDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .case }
  
  var name: TokenSyntax {
    let name = elements.map {
      let name = $0.name.trimmedDescription
      let associatedValue = $0.parameterClause?.trimmedDescription ?? ""
      return "\(name)\(associatedValue)"
    }.joined(separator: ",")
    return TokenSyntax(.identifier(name), presence: .present)
  }
}

extension PrecedenceGroupDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .precedencegroup }
}

extension MacroDeclSyntax: DeclProtocol {
  var keyword: DeclKeyword { .macro }
  var funcSignature: FunctionSignatureSyntax? { signature }
}
