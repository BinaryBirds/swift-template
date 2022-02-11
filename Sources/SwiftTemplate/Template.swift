//
//  Template.swift
//  SwiftTemplate
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

import Foundation
import GitKit
import PathKit
import PluralKit

public struct Template {
    
    public static let suffix = "-template"
    public static let directory = ".swift-template"
    public static let ignoreFile = ".swift-template-ignore"
    
    public struct Context {
        let name: String
        let project: String
        let author: String
        let date: Date
        
        public init(name: String,
                    project: String,
                    author: String,
                    date: Date = .init()
        ) {
            self.name = name
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
            "name": context.name,
            "Name": context.name.capitalizedFirstCharacter,
            "NAME": context.name.uppercased(),

            "names": context.name.pluralized(),
            "Names": context.name.pluralized().capitalizedFirstCharacter,
            "NAMES": context.name.pluralized().uppercased(),

            "project": context.project,
            "author": context.author,
            "date": dateFormatter.string(from: context.date)
        ]
    }
    
    func render(text: String) -> String {
        var result = text
        for (key, value) in parameters {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return result
    }

    func render(input: Path, output: Path) throws {
        let content = try String(contentsOf: input.url)
        let newName = render(text: input.url.lastPathComponent)
        let newContent = render(text: content)
        let newPath = output.child(newName)
        try newContent.write(to: newPath.url, atomically: true, encoding: .utf8)
    }
    
    func create(input: Path, output: Path, ignore: [String] = []) throws {
        for item in input.children() where !ignore.contains(item.url.lastPathComponent) {
            if item.isDirectory {
                let newName = render(text: item.name)
                let childPath = try output.add(newName)
                try create(input: item, output: childPath)
            }
            else {
                try render(input: item, output: output)
            }
        }
    }

    public func generate(output: String) throws {
        let inputPath = Path(input)
        let outputPath = try Path(output).add(context.name.capitalizedFirstCharacter)
        let ignoreFile = inputPath.child(Template.ignoreFile)
        let ignoreFileContents = (try? String(contentsOf: ignoreFile.url)) ?? ""
        var ignorePaths = ignoreFileContents.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
        ignorePaths.append(Template.ignoreFile)
        try create(input: inputPath, output: outputPath, ignore: ignorePaths)
    }
}
