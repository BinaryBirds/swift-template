//
//  Template.swift
//  SwiftTemplate
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#if canImport(Foundation)
import Foundation
#endif
#else
import Foundation
#endif

#if canImport(System)
import System
#else
import SystemPackage
#endif

extension FilePath {

    fileprivate var pathString: String {
        String(describing: self)
    }

    fileprivate var fileURL: URL {
        URL(fileURLWithPath: pathString)
    }

    fileprivate var name: String {
        fileURL.lastPathComponent
    }

    fileprivate var exists: Bool {
        FileManager.default.fileExists(atPath: pathString)
    }

    fileprivate var isDirectory: Bool {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(
            atPath: pathString,
            isDirectory: &isDirectory
        )
        return exists && isDirectory.boolValue
    }

    fileprivate func children() throws -> [FilePath] {
        try FileManager.default
            .contentsOfDirectory(atPath: pathString)
            .map { self.appending($0) }
    }

    fileprivate func createDirectory() throws {
        try FileManager.default.createDirectory(
            at: fileURL,
            withIntermediateDirectories: true
        )
    }
}

public struct Template {

    public static let suffix = "-template"
    public static let directory = ".swift-template"
    public static let ignoreFile = ".swift-template-ignore"

    public struct Context {
        let name: String
        let project: String
        let author: String
        let date: Date

        public init(
            name: String,
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

    public init(
        input: String,
        context: Context
    ) {
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
            "date": dateFormatter.string(from: context.date),
        ]
    }

    func render(
        text: String
    ) -> String {
        var result = text
        for (key, value) in parameters {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return result
    }

    func render(
        input: FilePath,
        output: FilePath
    ) throws {
        let content = try String(contentsOf: input.fileURL, encoding: .utf8)
        let newName = render(text: input.name)
        let newContent = render(text: content)
        let newPath = output.appending(newName)
        try newContent.write(
            to: newPath.fileURL,
            atomically: true,
            encoding: .utf8
        )
    }

    func create(
        input: FilePath,
        output: FilePath,
        ignore: [String] = []
    ) throws {
        for item in try input.children() where !ignore.contains(item.name) {
            if item.isDirectory {
                let newName = render(text: item.name)
                let childPath = output.appending(newName)
                try childPath.createDirectory()
                try create(input: item, output: childPath)
            }
            else {
                try render(input: item, output: output)
            }
        }
    }

    public func generate(
        output: String
    ) throws {
        let inputPath = FilePath(input)
        let outputPath = FilePath(output)
            .appending(context.name.capitalizedFirstCharacter)
        try outputPath.createDirectory()
        let ignoreFile = inputPath.appending(Template.ignoreFile)
        let ignoreFileContents =
            ignoreFile.exists
            ? ((try? String(contentsOf: ignoreFile.fileURL, encoding: .utf8))
                ?? "") : ""
        var ignorePaths = ignoreFileContents.split(separator: "\n")
            .map(String.init).filter { !$0.isEmpty }
        ignorePaths.append(Template.ignoreFile)
        ignorePaths.append(".DS_Store")
        ignorePaths.append(".git")

        try create(input: inputPath, output: outputPath, ignore: ignorePaths)
    }
}
