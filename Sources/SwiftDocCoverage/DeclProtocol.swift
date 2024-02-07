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

import Foundation
import SwiftSyntax


struct Comment {
  enum Kind {
    case line
    case block
    case docLine
    case docBlock
  }
  
  let kind: Kind
  let text: String
  
  var isDoc: Bool { kind == .docLine || kind == .docBlock }
}

public enum AccessLevel: Int {
  case `open`
  case `public`
  case `internal`
  case `fileprivate`
  case `private`
}

protocol DeclProtocol: SyntaxProtocol {
  
  // `attributes`: ``AttributeListSyntax``
  var modifiers: DeclModifierListSyntax { get }
  // `classKeyword`: `'class'`
  //var name: TokenSyntax { get }
  // `genericParameterClause`: ``GenericParameterClauseSyntax``?
  // `inheritanceClause`: ``InheritanceClauseSyntax``?
  // `genericWhereClause`: ``GenericWhereClauseSyntax``?
  // `memberBlock`: ``MemberBlockSyntax``

  var id: String { get }
}

extension DeclProtocol {

  var comments: [Comment] {
    return leadingTrivia.compactMap {
      switch $0 {
        case let .lineComment(text):
          return Comment(kind: .line, text: text)
        case let .blockComment(text):
          return Comment(kind: .block, text: text)
        case let .docLineComment(text):
          return Comment(kind: .docLine, text: text)
        case let .docBlockComment(text):
          return Comment(kind: .docBlock, text: text)
        default:
          return nil
      }
    }
  }
  
  var accessLevel: AccessLevel {
    for modifier in modifiers {
      let name = modifier.trimmed.description
      switch name {
        case "open":
          return .open
        case "public":
          return .public
        case "fileprivate":
          return .fileprivate
        case "private":
          return .private
        default:
          return .internal
      }
    }
    return .internal
  }
}

// MARK: -

extension TypeAliasDeclSyntax: DeclProtocol {
  var id: String {
    name.trimmed.description
  }
}

extension AssociatedTypeDeclSyntax: DeclProtocol {
  var id: String {
    name.trimmed.description
  }
}

extension ClassDeclSyntax: DeclProtocol {
  var id: String {
    let genericParameter = genericParameterClause?.trimmed.description ?? ""
    return "\(name.trimmed)\(genericParameter)"
  }
}

extension ActorDeclSyntax: DeclProtocol {
  var id: String {
    let genericParameter = genericParameterClause?.trimmed.description ?? ""
    return "\(name.trimmed)\(genericParameter)"
  }
}

extension StructDeclSyntax: DeclProtocol {
  var id: String {
    let genericParameter = genericParameterClause?.trimmed.description ?? ""
    return "\(name.trimmed)\(genericParameter)"
  }
}

extension ProtocolDeclSyntax: DeclProtocol {
  var id: String {
    name.trimmed.description
  }
}

extension ExtensionDeclSyntax: DeclProtocol {
  var id: String {
    extendedType.trimmed.description
  }
  
  var name: TokenSyntax {
    TokenSyntax(.identifier(extendedType.trimmedDescription), presence: .present)
  }
}

extension FunctionDeclSyntax: DeclProtocol {
  var id: String {
    let generic = genericParameterClause?.trimmed.description ?? ""
    return "\(name.trimmed)\(generic)\(signature.trimmed)"
  }
}

extension InitializerDeclSyntax: DeclProtocol {
  var id: String {
    let optionalMark = optionalMark?.trimmed.description ?? ""
    let generic = genericParameterClause?.trimmed.description ?? ""
    return "\(initKeyword.trimmed)\(optionalMark)\(generic)\(signature.trimmed)"
  }
}

extension SubscriptDeclSyntax: DeclProtocol {
  var id: String {
    let generic = genericParameterClause?.trimmed.description ?? ""
    return "\(subscriptKeyword.trimmed)\(generic)\(parameterClause.trimmed) \(returnClause.trimmed)"
  }
}

extension VariableDeclSyntax: DeclProtocol {
  var id: String {
    bindings.map { $0.pattern.trimmed.description }.joined(separator: ",")
  }
}

extension EnumDeclSyntax: DeclProtocol {
  var id: String {
    let generic = genericParameterClause?.trimmed.description ?? ""
    return "\(name.trimmed.description)\(generic)"
  }
}

extension EnumCaseDeclSyntax: DeclProtocol {
  var id: String {
    elements.map {
      let name = $0.name.trimmed.description
      let associatedValue = $0.parameterClause?.trimmed.description ?? ""
      return "\(name)\(associatedValue)"
    }.joined(separator: ",")
  }
}

extension PrecedenceGroupDeclSyntax: DeclProtocol {
  var id: String {
    "\(precedencegroupKeyword.trimmed) \(name.trimmed)"
  }
}

extension MacroDeclSyntax: DeclProtocol {
  var id: String {
    let generic = genericParameterClause?.trimmed.description ?? ""
    return "\(name.trimmed)\(generic)\(signature.trimmed)"
  }
}
