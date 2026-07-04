import ArgumentParser

@main
struct SwiftTemplateCLI: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swift-template",
        abstract: "Swift Template Engine",
        subcommands: [
            ListCommand.self,
            GenerateCommand.self,
            InstallCommand.self,
            UpdateCommand.self,
            CreateCommand.self,
            RemoveCommand.self,
        ],
        defaultSubcommand: ListCommand.self
    )
}
