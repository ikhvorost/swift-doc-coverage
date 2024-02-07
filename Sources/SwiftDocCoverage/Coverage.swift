//  Coverage.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 05.08.2022.
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


extension String : LocalizedError {
  public var errorDescription: String? { self }
}

fileprivate func findFiles(path: String, ext: String, skipsHiddenFiles: Bool, ignoreFilenameRegex: String) throws -> [URL]  {
  var isDirectory: ObjCBool = false
  guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
    throw "Path not found."
  }
  
  if isDirectory.boolValue {
    var urls = [URL]()
    
    let regex: NSRegularExpression? = ignoreFilenameRegex.isEmpty ? nil : try NSRegularExpression(pattern: ignoreFilenameRegex)
    
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
          let fileName = fileURL.lastPathComponent
          let range = NSRange(location: 0, length: fileName.utf16.count)
          if regex.firstMatch(in: fileName, range: range) != nil {
            continue
          }
        }
        
        urls.append(fileURL)
      }
    }
    return urls
  }
  
  guard path.hasSuffix(ext) else {
    throw "Not swift file."
  }
  let url = URL(fileURLWithPath: path)
  return [url]
}

public struct Coverage {
  let urls: [URL]
  let minAccessLevel: AccessLevel
  let output: Output
  
  private let dateComponentsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.hour, .minute, .second]
    return formatter
  }()
  
  public init(paths: [String], skipsHiddenFiles: Bool = true, ignoreFilenameRegex: String = "", minAccessLevel: AccessLevel = .public, output: Output = TerminalOutput()) throws {
    self.urls = try paths.flatMap {
      try findFiles(path: $0, ext: ".swift", skipsHiddenFiles: skipsHiddenFiles, ignoreFilenameRegex: ignoreFilenameRegex)
    }
    guard urls.count > 0 else {
      throw "Swift files not found."
    }
    self.minAccessLevel = minAccessLevel
    self.output = output
  }
  
  private func string(from timeInterval: TimeInterval) -> String {
    guard var time = dateComponentsFormatter.string(from: timeInterval) else {
      return ""
    }
    
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
  
  @discardableResult
  func report(_ body: ((SourceReport, TimeInterval) -> Void)? = nil) throws -> CoverageReport {
    precondition(urls.count > 0)
    
    var sources = [SourceReport]()
    
    try urls.forEach { url in
      let time = Date()
      
      let source = try Source(fileURL: url, minAccessLevel: minAccessLevel)
      guard source.declarations.count > 0 else {
        return
      }
      
      let undocumented = source.undocumented.map { DeclarationReport(line: $0.line, column: $0.column, name: $0.name) }
      let sourceReport = SourceReport(path: url.path,
                                      totalCount: source.declarations.count,
                                      undocumented: undocumented)
      sources.append(sourceReport)
      
      body?(sourceReport, -time.timeIntervalSinceNow)
    }
    
    guard sources.count > 0 else {
      throw "Declarations not found."
    }
    
    return CoverageReport(sources: sources)
  }
  
  public func reportStatistics() throws {
    var i = 1
    var time: TimeInterval = 0
    let report = try report() { source, timeInterval in
      time += timeInterval
      
      output.write("\(i)) \(source.path): \(source.coverage)% [\(source.totalCount - source.undocumented.count)/\(source.totalCount)] (\(string(from: timeInterval)))")
      
      if source.undocumented.count > 0 {
        output.write("Undocumented:")
        
        source.undocumented.forEach {
          output.write("<\(source.fileName):\($0.line):\($0.column)> \($0.name)")
        }
        
        output.write("\n", terminator: "")
      }
      
      i += 1
    }
    output.write("\nTotal: \(report.coverage)% [\(report.totalCount - report.totalUndocumentedCount)/\(report.totalCount)] (\(string(from: time)))")
  }
  
  public func reportWarnings() throws {
    try report { source, _ in
      source.undocumented.forEach {
        output.write("\(source.path):\($0.line):\($0.column): warning: No documentation for '\($0.name)'.")
      }
    }
  }
  
  public func reportJson() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    let report = try report()
    let data = try encoder.encode(report)
    let json = String(data: data, encoding: .utf8)!
    
    output.write(json)
  }
}
