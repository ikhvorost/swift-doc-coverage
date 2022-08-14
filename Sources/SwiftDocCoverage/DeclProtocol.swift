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
}

enum AccessLevel: Int {
    case `open`
    case `public`
    case `internal`
    case `fileprivate`
    case `private`
}

protocol DeclProtocol: SyntaxProtocol {
    var id: String { get }
    var modifiers: ModifierListSyntax? { get }
}

extension DeclProtocol {
    
    var comments: [Comment] {
        guard let trivia = leadingTrivia else {
            return []
        }
        
        return trivia.compactMap {
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
        guard let modifiers = modifiers else {
            return .internal
        }

        for modifier in modifiers {
            let name = modifier.withoutTrivia().description
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
    
    func location(sourceLocationConverter: SourceLocationConverter) -> SourceLocation {
        startLocation(converter: sourceLocationConverter, afterLeadingTrivia: true)
    }
}

// MARK: -

extension TypealiasDeclSyntax: DeclProtocol {
    var id: String {
        identifier.withoutTrivia().description
    }
}

extension AssociatedtypeDeclSyntax: DeclProtocol {
    var id: String {
        identifier.withoutTrivia().description
    }
}

extension ClassDeclSyntax: DeclProtocol {
    var id: String {
        let genericParameter = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia())\(genericParameter)"
    }
}

extension StructDeclSyntax: DeclProtocol {
    var id: String {
        let genericParameter = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia())\(genericParameter)"
    }
}

extension ProtocolDeclSyntax: DeclProtocol {
    var id: String {
        identifier.withoutTrivia().description
    }
}

extension ExtensionDeclSyntax: DeclProtocol {
    var id: String {
        extendedType.withoutTrivia().description
    }
}

extension FunctionDeclSyntax: DeclProtocol {
    var id: String {
        let generic = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia())\(generic)\(signature.withoutTrivia())"
    }
}

extension InitializerDeclSyntax: DeclProtocol {
    var id: String {
        let optionalMark = optionalMark?.withoutTrivia().description ?? ""
        let generic = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(initKeyword.withoutTrivia())\(optionalMark)\(generic)\(parameters.withoutTrivia())"
    }
}

extension SubscriptDeclSyntax: DeclProtocol {
    var id: String {
        let generic = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(subscriptKeyword.withoutTrivia())\(generic)\(indices.withoutTrivia()) \(result.withoutTrivia())"
    }
}

extension VariableDeclSyntax: DeclProtocol {
    var id: String {
        bindings.map { $0.pattern.withoutTrivia().description }.joined(separator: ",")
    }    
}

extension EnumDeclSyntax: DeclProtocol {
    var id: String {
        let generic = genericParameters?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia().description)\(generic)"
    }
}

extension EnumCaseDeclSyntax: DeclProtocol {
    var id: String {
        elements.map {
            let name = $0.identifier.withoutTrivia().description
            let associatedValue = $0.associatedValue?.withoutTrivia().description ?? ""
            return "\(name)\(associatedValue)"
        }.joined(separator: ",")
    }
}

extension OperatorDeclSyntax: DeclProtocol {
    var id: String {
        "\(operatorKeyword.withoutTrivia()) \(identifier.withoutTrivia())"
    }
}

extension PrecedenceGroupDeclSyntax: DeclProtocol {
    var id: String {
        "\(precedencegroupKeyword.withoutTrivia()) \(identifier.withoutTrivia())"
    }
}
