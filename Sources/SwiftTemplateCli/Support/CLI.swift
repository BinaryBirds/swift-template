import ArgumentParser
import Subprocess
import SwiftTemplate

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

enum CLIError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}

enum CLI {

    static var currentDirectory: FilePath {
        FilePath(FileManager.default.currentDirectoryPath)
    }

    static var homeDirectory: FilePath {
        FilePath(NSHomeDirectory())
    }

    static func resolvePath(_ path: String) -> FilePath {
        FilePath((path as NSString).expandingTildeInPath)
    }

    static func templatesDirectory(global: Bool) -> FilePath {
        (global ? homeDirectory : currentDirectory)
            .appending(Template.directory)
    }

    static func templatePath(named name: String, global: Bool) -> FilePath {
        templatesDirectory(global: global).appending(name + Template.suffix)
    }

    static func preferredTemplatePath(named name: String) -> FilePath? {
        let localPath = templatePath(named: name, global: false)
        if localPath.isDirectory {
            return localPath
        }
        let globalPath = templatePath(named: name, global: true)
        if globalPath.isDirectory {
            return globalPath
        }
        return nil
    }

    static func projectName(in directory: FilePath) throws -> String? {
        try directory.children()
            .first { ["xcodeproj", "xcworkspace"].contains($0.pathExtension) }
            .map { $0.fileURL.deletingPathExtension().lastPathComponent }
    }

    static func gitUserName() async -> String? {
        do {
            let output = try await runCommand(
                "git",
                arguments: ["config", "--global", "user.name"]
            )
            return output.nilIfEmpty
        }
        catch {
            return nil
        }
    }

    @discardableResult
    static func runCommand(
        _ executable: String,
        arguments: [String] = [],
        workingDirectory: FilePath? = nil
    ) async throws -> String {
        let result = try await run(
            .name(executable),
            arguments: Arguments(arguments),
            workingDirectory: workingDirectory,
            output: .string(limit: 1_048_576),
            error: .string(limit: 1_048_576)
        )
        guard result.terminationStatus.isSuccess else {
            let errorOutput = result.standardError?.trimmed.nilIfEmpty
            let commandDescription = ([executable] + arguments)
                .joined(separator: " ")
            throw CLIError.message(
                errorOutput
                    ?? "Command failed: \(commandDescription) (\(result.terminationStatus))"
            )
        }
        return result.standardOutput?.trimmed ?? ""
    }

    static func prompt(_ message: String) -> String? {
        print(message, terminator: " ")
        return readLine()
    }

    #if os(macOS)
    static func openInFinder(_ path: FilePath) async throws {
        _ = try await runCommand(
            "open",
            arguments: ["-a", "Finder", path.pathString]
        )
    }
    #endif
}

extension String {

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

extension FilePath {

    var pathString: String {
        String(describing: self)
    }

    var fileURL: URL {
        URL(fileURLWithPath: pathString)
    }

    var name: String {
        fileURL.lastPathComponent
    }

    var pathExtension: String {
        fileURL.pathExtension
    }

    var exists: Bool {
        FileManager.default.fileExists(atPath: pathString)
    }

    var isDirectory: Bool {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(
            atPath: pathString,
            isDirectory: &isDirectory
        )
        return exists && isDirectory.boolValue
    }

    var isVisible: Bool {
        !name.hasPrefix(".")
    }

    func children() throws -> [FilePath] {
        guard exists else {
            return []
        }
        return try FileManager.default
            .contentsOfDirectory(atPath: pathString)
            .map { self.appending($0) }
    }

    func createDirectoryIfNeeded() throws {
        try FileManager.default.createDirectory(
            at: fileURL,
            withIntermediateDirectories: true
        )
    }

    func removeFromDisk() throws {
        try FileManager.default.removeItem(at: fileURL)
    }

    func write(_ contents: String) throws {
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
