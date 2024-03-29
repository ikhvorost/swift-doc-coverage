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
import SwiftSource


enum Errors: String {
  case cantOpenFile = "Can't open file."
  case filesNotFound = "Swift files not found."
  case declarationsNotFound = "Swift declarations not found."
  case pathNotFound = "Path not found."
  case notSwiftFile = "Not swift file."
}

extension Errors: LocalizedError {
  public var errorDescription: String? { self.rawValue }
}


enum AccessLevel: String, ExpressibleByArgument {
  case open, `public`, `internal`, `fileprivate`, `private`
  
  var accessLevel: SwiftAccessLevel {
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
  case coverage
  case warnings
  case json
}

struct SwiftDocCoverage: ParsableCommand {
  
  static var configuration = CommandConfiguration(
    abstract: "Generates documentation coverage statistics for Swift files.",
    version: "1.1.0"
  )
  
  @Argument(help: "One or more paths to directories or Swift files.")
  var inputs: [String]
  
  @Option(name: .shortAndLong, help: "An option to skip hidden files.")
  var skipsHiddenFiles: Bool = true
  
  @Option(name: .shortAndLong, help: "Skip source code files with file paths that match the given regular expression.")
  var ignoreRegex: String = ""
  
  @Option(name: .shortAndLong, help: "The minimum access level of the symbols considered for coverage statistics: \(AccessLevel.open), \(AccessLevel.public), \(AccessLevel.internal), \(AccessLevel.fileprivate), \(AccessLevel.private).")
  var minimumAccessLevel: AccessLevel = .public
  
  @Option(name: .shortAndLong, help: "Report modes: \(ReportArgument.coverage.rawValue), \(ReportArgument.warnings.rawValue), \(ReportArgument.json.rawValue).")
  var report: ReportArgument = .coverage
  
  @Option(name: .shortAndLong, help: "The file path for generated report.")
  var output: String?
  
  private enum CodingKeys: String, CodingKey {
    case inputs, skipsHiddenFiles, ignoreRegex, minimumAccessLevel, report, output
  }
  
  var sources: [SwiftSource] = []
  var out: Output? = nil
  
  mutating func run() throws {
    // Output
    if out == nil {
      if let output = output {
        if let file = try FileOutput(path: output) {
          out = file
        }
        else {
          throw Errors.cantOpenFile
        }
      }
      else {
        out = TerminalOutput()
      }
    }
    
    let urls = try inputs.flatMap {
      try Self.files(path: $0, ext: ".swift", skipsHiddenFiles: skipsHiddenFiles, ignoreRegex: ignoreRegex)
    }
    
    guard urls.count > 0 else {
      throw Errors.filesNotFound
    }
    
    let totalTime = Date()
    var index = 0
    
    // Sources
    sources = try urls.map { url in
      let sourceTime = Date()
      
      let source = try SwiftSource(url: url)
      
      if report != .json {
        let declarations = source.declarations(accessLevel: minimumAccessLevel.accessLevel)
        if declarations.count > 0 {
          index += 1
          if report == .coverage {
            Self.coverage(index: index, time: sourceTime, path: url.path, declarations: declarations, out: out)
          }
          else if report == .warnings {
            Self.warnings(path: url.path, declarations: declarations, out: out)
          }
        }
      }
      
      return source
    }
    
    if report == .coverage {
      let declarations = sources.flatMap { $0.declarations(accessLevel: minimumAccessLevel.accessLevel) }
      guard declarations.count > 0 else {
        throw Errors.declarationsNotFound
      }
      
      let undocumented = declarations.filter { $0.hasDoc == false }
      
      let totalCount = declarations.count
      let documentedCount = totalCount - undocumented.count
      let coverage = documentedCount * 100 / totalCount
      
      out?.write("\nTotal: \(coverage)% [\(documentedCount)/\(totalCount)] (\(Self.string(from: -totalTime.timeIntervalSinceNow)))")
    }
    else if report == .json {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted

      let data = try encoder.encode(sources)
      let json = String(data: data, encoding: .utf8)!

      out?.write(json)
    }
  }
  
  static func run(output: Output? = nil, _ arguments: String...) throws -> Self {
    var cmd = try Self.parse(arguments)
    cmd.out = output
    try cmd.run()
    return cmd
  }
  
  static func files(path: String, ext: String, skipsHiddenFiles: Bool, ignoreRegex: String) throws -> [URL] {
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
      throw Errors.pathNotFound
    }
    
    if isDirectory.boolValue {
      var urls = [URL]()
      
      let regex: NSRegularExpression? = ignoreRegex.isEmpty
        ? nil
        : try NSRegularExpression(pattern: ignoreRegex)
      
      let url = URL(fileURLWithPath: path)
      let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
      let options: FileManager.DirectoryEnumerationOptions = skipsHiddenFiles ? [.skipsHiddenFiles] : []
      if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey, .isHiddenKey], options: options) {
        for case let fileURL as URL in enumerator {
          guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues.isDirectory, !isDirectory,
                let name = resourceValues.name,
                name.hasSuffix(ext)
          else {
            continue
          }
          
          // Skip by regex
          if let regex = regex {
            let path = fileURL.path
            if regex.firstMatch(in: path, range: NSRange(path.startIndex..., in: path)) != nil {
              continue
            }
          }
          
          urls.append(fileURL)
        }
      }
      return urls
    }
    
    guard path.hasSuffix(ext) else {
      throw Errors.notSwiftFile
    }
    let url = URL(fileURLWithPath: path)
    return [url]
  }
  
  static var dateFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.hour, .minute, .second]
    return formatter
  }()
  
  static func string(from timeInterval: TimeInterval) -> String {
    var time = dateFormatter.string(from: timeInterval)!
    
    guard let fraction = String(format: "%.3f", timeInterval).split(separator: ".").last, fraction != "000" else {
      return time
    }
    let ms = ".\(fraction)"
    
    guard let range = time.range(of: "s") else {
      return "\(time) 0\(ms)\("s")"
    }
    
    time.insert(contentsOf: ms, at: range.lowerBound)
    return time
  }
  
  static func coverage(index: Int, time: Date, path: String, declarations: [SwiftDeclaration], out: Output?) {
    assert(declarations.count > 0)
    
    let undocumented = declarations.filter { $0.hasDoc == false }
    
    let totalCount = declarations.count
    let documentedCount = totalCount - undocumented.count
    let coverage = documentedCount * 100 / totalCount
    
    out?.write("\(index)) \(path): \(coverage)% [\(documentedCount)/\(totalCount)] (\(string(from: -time.timeIntervalSinceNow)))")
    
    if undocumented.count > 0 {
      let fileName = NSString(string: path).lastPathComponent
      
      out?.write("Undocumented:")
      undocumented.forEach {
        out?.write("<\(fileName):\($0.line):\($0.column)> \($0.name)")
      }
      out?.write("\n", terminator: "")
    }
  }
  
  static func warnings(path: String, declarations: [SwiftDeclaration], out: Output?) {
    assert(declarations.count > 0)
    
    declarations
      .filter { $0.hasDoc == false }
      .forEach {
        out?.write("\(path):\($0.line):\($0.column): warning: No documentation for '\($0.name)'.")
      }
  }
}

SwiftDocCoverage.main()
