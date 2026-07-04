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

struct ListCommand: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List installed templates"
    )

    private func printTemplates(
        at path: FilePath,
        flag: String = ""
    ) throws {
        for path in try path.children().filter(\.isDirectory).filter(\.isVisible).sorted(by: { $0.name < $1.name }) {
            let name = path.name.replacingOccurrences(
                of: Template.suffix,
                with: ""
            )
            print(flag.isEmpty ? name : "\(name) \(flag)")
        }
    }

    mutating func run() async throws {
        try printTemplates(at: CLI.templatesDirectory(global: false))
        try printTemplates(
            at: CLI.templatesDirectory(global: true),
            flag: "(global)"
        )
    }
}
