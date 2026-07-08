import ArgumentParser
import SwiftTemplate

#if canImport(FoundationEssentials)
import FoundationEssentials
#if canImport(Foundation)
import Foundation
#endif
#else
import Foundation
#endif

struct InstallCommand: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install a new template from a given git repository."
    )

    @Argument(help: "The url of the template repository")
    var url: String

    @Flag(
        name: [.customLong("global"), .short],
        help: "Install into the global template directory"
    )
    var global = false

    mutating func run() async throws {
        let path = CLI.templatesDirectory(global: global)
        try path.createDirectoryIfNeeded()

        _ = try await CLI.runCommand(
            "git",
            arguments: ["clone", url],
            workingDirectory: path
        )

        let repositoryName =
            URL(string: url)?
            .deletingPathExtension()
            .lastPathComponent
            .replacingOccurrences(of: Template.suffix, with: "") ?? "unknown"

        print("Template `\(repositoryName)` installed to: \(path.pathString)")
    }
}
