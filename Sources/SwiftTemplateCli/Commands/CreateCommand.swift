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

struct CreateCommand: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new Swift template"
    )

    @Argument(help: "The name of the template")
    var name: String

    @Flag(
        name: [.customLong("global"), .short],
        help: "Create the template in the global template directory"
    )
    var global = false

    mutating func run() async throws {
        let templatesDirectory = CLI.templatesDirectory(global: global)
        let templatePath = templatesDirectory.appending(name + Template.suffix)

        guard !templatePath.exists else {
            throw ValidationError(
                "Template already exists at \(templatePath.pathString)."
            )
        }

        try templatesDirectory.createDirectoryIfNeeded()
        try templatePath.createDirectoryIfNeeded()

        let readme = """
            # \(name)

            A basic Swift template.

            You can use the following parameters by default (even in file names):

                * {module} - name of the generated module
                * {project} - project name
                * {author} - author name
                * {date} - date of creation

            You can deploy the template using:

                * git remote add origin [url]
                * git push -u origin master

            You can ignore files from the template by adding them to the \(Template.ignoreFile) file.
            """

        try Template.ignoreFile.write(
            to: templatePath.appending(Template.ignoreFile).fileURL,
            atomically: true,
            encoding: .utf8
        )
        try readme.write(
            to: templatePath.appending("README.md").fileURL,
            atomically: true,
            encoding: .utf8
        )

        _ = try await CLI.runCommand(
            "git",
            arguments: ["init"],
            workingDirectory: templatePath
        )

        print("Template ready at: \(templatePath.pathString)")

        #if os(macOS)
        try? await CLI.openInFinder(templatePath)
        #endif
    }
}
