//  SourceFile.swift
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
import SwiftSyntaxParser


fileprivate class Visitor: SyntaxVisitor {
    var declarations = [DeclProtocol]()
    
    init(sourceFile: SourceFileSyntax) {
        super.init()
        walk(sourceFile)
    }
   
     // MARK: - SyntaxVisitor
     /*
     override func visit(_ node: AssociatedtypeDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(AssociatedType.self, node))
     return .skipChildren
     }
*/
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        declarations.append(node)
        return .visitChildren
    }
    /*
     override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Enumeration.self, node))
     return .visitChildren
     }
     
     override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
     let cases = node.elements.compactMap { element in
     Enumeration.Case(element.withRawValue(nil))
     }
     
     for `case` in cases {
     push(symbol(node, api: `case`))
     }
     
     return .skipChildren
     }
     
     override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
     push(Extension(node))
     return .visitChildren
     }
     
     override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Function.self, node))
     return .skipChildren
     }
     
     override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
     return .visitChildren
     }
     
     override func visit(_ node: IfConfigClauseSyntax) -> SyntaxVisitorContinueKind {
     assert(node.parent?.is(IfConfigClauseListSyntax.self) == true)
     assert(node.parent?.parent?.is(IfConfigDeclSyntax.self) == true)
     
     let block = ConditionalCompilationBlock(node.parent!.parent!.as(IfConfigDeclSyntax.self)!)
     let branch = ConditionalCompilationBlock.Branch(node)
     push(CompilationCondition(block: block, branch: branch))
     
     return .visitChildren
     }
     
     override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
     push(Import(node))
     return .skipChildren
     }
     
     override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Initializer.self, node))
     return .skipChildren
     }
     
     override func visit(_ node: OperatorDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Operator.self, node))
     return .skipChildren
     }
     
     override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(PrecedenceGroup.self, node))
     return .skipChildren
     }
     
     override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Protocol.self, node))
     return .visitChildren
     }
     
     override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Subscript.self, node))
     return .skipChildren
     }
     
     override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Structure.self, node))
     return .visitChildren
     }
     
     override func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
     push(symbol(Typealias.self, node))
     return .skipChildren
     }
     
     override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
     let variables = node.bindings.compactMap { Variable($0) }
     for variable in variables {
     push(symbol(node, api: variable))
     }
     
     return .skipChildren
     }
     */
}

struct SourceFile {
    let fileURL: URL
    let sourceLocationConverter: SourceLocationConverter
    let declarations: [DeclProtocol]
    
    init(fileURL: URL) throws {
        self.fileURL = fileURL
        let sourceFile = try SyntaxParser.parse(fileURL)
        sourceLocationConverter = SourceLocationConverter(file: fileURL.absoluteString, tree: sourceFile)
        let visitor = Visitor(sourceFile: sourceFile)
        declarations = visitor.declarations
    }
}
