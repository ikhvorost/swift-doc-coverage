//  Output.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 25.08.2022.
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

class Output {
    let stream: UnsafeMutablePointer<FILE>
    
    init(stream: UnsafeMutablePointer<FILE>) {
        self.stream = stream
    }
    
    func write(_ text: String, terminator: String = "\n") {
        fputs(text, stream)
        fputs(terminator, stream)
    }
}

class TerminalOutput: Output {
    
    init() {
        super.init(stream: Darwin.stdout)
    }
}

class FileOutput: Output {
    init(path: String) throws {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
        else {
            let dir = NSString(string: path).deletingLastPathComponent
            try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }
        
        guard let file = fopen(path.cString(using: .utf8), "w".cString(using: .utf8)) else {
            throw "Can't open file."
        }
        super.init(stream: file)
    }
    
    deinit {
        fclose(stream)
    }
}
