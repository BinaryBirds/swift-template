import ArgumentParser

@main
struct Entrypoint: AsyncParsableCommand {

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
        ]
    )
}
