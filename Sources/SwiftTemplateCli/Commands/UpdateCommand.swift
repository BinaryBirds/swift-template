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
#if canImport(System)
import System
#else
import SystemPackage
#endif

struct UpdateCommand: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update installed templates"
    )

    mutating func run() async throws {
        let templates =
            try CLI.templatesDirectory(global: false).children()
            + CLI.templatesDirectory(global: true).children()

        for path in templates.filter(\.isDirectory).filter(\.isVisible)
            .sorted(by: { $0.name < $1.name })
        {
            do {
                _ = try await CLI.runCommand(
                    "git",
                    arguments: ["pull"],
                    workingDirectory: path
                )
                let name = path.name.replacingOccurrences(
                    of: Template.suffix,
                    with: ""
                )
                print("Template `\(name)` updated.")
            }
            catch {
                throw CLIError.message(
                    "Failed to update `\(path.name)`: \(error.localizedDescription)"
                )
            }
        }
    }
}
