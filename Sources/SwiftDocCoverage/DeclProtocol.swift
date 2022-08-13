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

enum AccessLevel: Int {
    case `open`
    case `public`
    case `internal`
    case `fileprivate`
    case `private`
}

extension AccessLevel : CustomStringConvertible {
    var description: String {
        switch self {
        case .open:
            return "open"
        case .public:
            return "public"
        case .internal:
            return "internal"
        case .fileprivate:
            return "fileprivate"
        case .private:
            return "private"
        }
    }
}

protocol DeclProtocol: SyntaxProtocol {
    var id: String { get }
    var accessLevel: AccessLevel { get }
}

extension DeclProtocol {
    
    var documentation: [String]? {
        let items: [String]? = leadingTrivia?.compactMap {
            if case let .docLineComment(text) = $0 {
                return text
            }
            else if case let .docBlockComment(text) = $0 {
                return text
            }
            return nil
        }
        return items?.count != 0 ? items : nil
    }
    
    func accessLevel(modifierList: ModifierListSyntax?) -> AccessLevel {
        guard let modifierList = modifierList else {
            return .internal
        }
        
        let tokenKinds = modifierList.map { $0.name.tokenKind }
        for kind in tokenKinds {
            if case let .identifier(text) = kind, text == "open" {
                return .open
            }
            else if kind == .publicKeyword {
                return .public
            }
            else if kind == .fileprivateKeyword {
                return .fileprivate
            }
            else if kind == .privateKeyword {
                return .private
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
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        identifier.withoutTrivia().description
    }
}

extension AssociatedtypeDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        identifier.withoutTrivia().description
    }
}

extension ClassDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        let genericParameter = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia())\(genericParameter)"
    }
}

extension StructDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        let genericParameter = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia())\(genericParameter)"
    }
}

extension ProtocolDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        identifier.withoutTrivia().description
    }
}

extension ExtensionDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        extendedType.withoutTrivia().description
    }
}

extension FunctionDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        let generic = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia())\(generic)\(signature.withoutTrivia())"
    }
}

extension InitializerDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        let optionalMark = optionalMark?.withoutTrivia().description ?? ""
        let generic = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(initKeyword.withoutTrivia())\(optionalMark)\(generic)\(parameters.withoutTrivia())"
    }
}

extension SubscriptDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        let generic = genericParameterClause?.withoutTrivia().description ?? ""
        return "\(subscriptKeyword.withoutTrivia())\(generic)\(indices.withoutTrivia()) \(result.withoutTrivia())"
    }
}

extension VariableDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        bindings.map { $0.pattern.withoutTrivia().description }.joined(separator: ",")
    }    
}

extension EnumDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        let generic = genericParameters?.withoutTrivia().description ?? ""
        return "\(identifier.withoutTrivia().description)\(generic)"
    }
}

extension EnumCaseDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        elements.map {
            let name = $0.identifier.withoutTrivia().description
            let associatedValue = $0.associatedValue?.withoutTrivia().description ?? ""
            return "\(name)\(associatedValue)"
        }.joined(separator: ",")
    }
}

extension OperatorDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        "\(operatorKeyword.withoutTrivia()) \(identifier.withoutTrivia())"
    }
}

extension PrecedenceGroupDeclSyntax: DeclProtocol {
    var accessLevel: AccessLevel {
        accessLevel(modifierList: modifiers)
    }
    
    var id: String {
        "\(precedencegroupKeyword.withoutTrivia()) \(identifier.withoutTrivia())"
    }
}
