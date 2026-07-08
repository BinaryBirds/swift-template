import ArgumentParser
import SwiftTemplate

#if canImport(System)
import System
#else
import SystemPackage
#endif

struct RemoveCommand: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Removes an installed template"
    )

    @Argument(help: "The name of the template")
    var name: String

    private func removeTemplate(at path: FilePath) throws {
        let answer = CLI.prompt("Remove `\(path.pathString)`? [y/N]")
        guard answer?.lowercased() == "y" else {
            print("Skipping template removal.")
            return
        }

        try path.removeFromDisk()
        print("Template removed.")
    }

    mutating func run() async throws {
        let templateName = name + Template.suffix
        let localPath = CLI.templatesDirectory(global: false)
            .appending(templateName)
        let globalPath = CLI.templatesDirectory(global: true)
            .appending(templateName)

        var toRemove: [FilePath] = []
        if localPath.isDirectory {
            toRemove.append(localPath)
        }
        if globalPath.isDirectory {
            toRemove.append(globalPath)
        }

        guard !toRemove.isEmpty else {
            print("No such template.")
            return
        }

        for path in toRemove {
            try removeTemplate(at: path)
        }
    }
}
