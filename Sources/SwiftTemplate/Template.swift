//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

import Foundation
import GitKit
import PathKit

public struct Template {
    
    public static let suffix = "-template"
    public static let directory = ".swift-template"
    public static let ignoreFile = ".swift-template-ignore"
    
    public struct Context {
        let module: String
        let project: String
        let author: String
        let date: Date
        
        public init(module: String,
                    project: String,
                    author: String,
                    date: Date = .init()
        ) {
            self.module = module
            self.project = project
            self.author = author
            self.date = date
        }
    }

    let input: String
    let context: Context

    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    public init(input: String, context: Context) {
        self.input = input
        self.context = context
    }

    var parameters: [String: String] {
        [
            "module": self.context.module,
            "project": self.context.project,
            "author": self.context.author,
            "date": self.dateFormatter.string(from: self.context.date)
        ]
    }
    
    func render(text: String) -> String {
        var result = text
        for (key, value) in self.parameters {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return result
    }

    func render(input: Path, output: Path) throws {
        let content = try String(contentsOf: input.url)
        let newName = self.render(text: input.url.lastPathComponent)
        let newContent = self.render(text: content)
        let newPath = output.child(newName)
        try newContent.write(to: newPath.url, atomically: true, encoding: .utf8)
    }
    
    func create(input: Path, output: Path, ignore: [String] = []) throws {
        for item in input.children().filter(\.isVisible) {
            guard !ignore.contains(item.url.lastPathComponent) else {
                continue
            }
            if item.isDirectory {
                let childPath = try output.add(item.name)
                try self.create(input: item, output: childPath)
            }
            else {
                try self.render(input: item, output: output)
            }
        }
    }

    public func generate(output: String) throws {
        let inputPath = Path(self.input)
        let outputPath = try Path(output).add(self.context.module)
        let ignorePath = inputPath.child(Template.ignoreFile)
        let ignoreFile = (try? String(contentsOf: ignorePath.url)) ?? ""
        let ignore = ignoreFile.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
        try self.create(input: inputPath, output: outputPath, ignore: ignore)
    }
}
