//  main.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 23.08.2022.
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
import ArgumentParser


// --report-style: text, warnings, json

enum AccessLevelArgument: String, ExpressibleByArgument {
    case open, `public`, `internal`, `fileprivate`, `private`
    
    var accessLevel: AccessLevel {
        switch self {
        case .open: return .open
        case .public: return .public
        case .internal: return .internal
        case .fileprivate: return .fileprivate
        case .private: return .private
        }
    }
}

enum ReportArgument: String, ExpressibleByArgument {
    case statistics
    case warnings
}

struct SwiftDocCoverage: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "Generates documentation coverage statistics for Swift files.",
        version: "1.0.0"
    )
    
    @Argument(help: "One or more paths to a directory containing Swift files.")
    var inputs: [String]
    
    @Option(name: .shortAndLong, help: "The minimum access level of the symbols considered for coverage statistics: \(AccessLevelArgument.open), \(AccessLevelArgument.public), \(AccessLevelArgument.internal), \(AccessLevelArgument.fileprivate), \(AccessLevelArgument.private).")
    var minimumAccessLevel: AccessLevelArgument = .public
    
    @Option(name: .shortAndLong, help: "Report modes: \(ReportArgument.statistics.rawValue), \(ReportArgument.warnings.rawValue).")
    var report: ReportArgument = .statistics
    
    @Option(name: .shortAndLong, help: "The file path for generated report.")
    var output: String?
    
    mutating func run() throws {
        
        let out: Output = output != nil
            ? try FileOutput(path: output!)
            : TerminalOutput()
        
        let coverage = try Coverage(paths: inputs,
                                    minAccessLevel: minimumAccessLevel.accessLevel,
                                    output: out)
        
        switch report {
        case .statistics:
            coverage.printStatistics()
        case .warnings:
            coverage.printWarnings()
        }
    }
}

SwiftDocCoverage.main()
