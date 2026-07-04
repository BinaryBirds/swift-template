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

struct GenerateCommand: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generates Swift code based on a given template"
    )

    @Argument(help: "The name of the generated product")
    var name: String

    @Option(name: [.customLong("use"), .short], help: "Template name to use")
    var use: String

    @Option(
        name: [.customLong("output"), .short],
        help: "Generated output path"
    )
    var output: String?

    mutating func run() async throws {
        guard let templatePath = CLI.preferredTemplatePath(named: use) else {
            throw ValidationError(
                "Invalid template, use the list command to show available options."
            )
        }

        let outputPath = output.map(CLI.resolvePath) ?? CLI.currentDirectory
        guard outputPath.isDirectory else {
            throw ValidationError("Output path is not a valid directory.")
        }

        let project = try CLI.projectName(in: CLI.currentDirectory) ?? name
        let author = await CLI.gitUserName() ?? "swift-template"

        let template = Template(
            input: templatePath.pathString,
            context: .init(
                name: name,
                project: project,
                author: author
            )
        )

        try template.generate(output: outputPath.pathString)
        print("Template generated.")
    }
}
