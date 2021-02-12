//
//  GenerateCommand.swift
//  SwiftTemplateCli
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

import Foundation
import ConsoleKit
import PathKit
import GitKit
import SwiftTemplate

final class GenerateCommand: Command {
    
    static let name = "generate"

    let help = "Generates Swift code based on a given template"
        
    struct Signature: CommandSignature {

        @Argument(name: "name", help: "The name of the generated product")
        var name: String

        @Option(name: "use", short: "u", help: "Template name to use")
        var use: String?
        
        @Option(name: "output", short: "o", help: "Generated output path")
        var output: String?
    }

    func run(using context: CommandContext, signature: Signature) throws {
        guard let templateName = signature.use else {
            context.console.error("You have to specify a template name via the --use (-u) option.")
            return
        }
        let currentPath = Path.current
        let workPath = Path.home.child(Template.directory)
        let templatePath = workPath.child(templateName + Template.suffix)
        let localPath = currentPath.child(Template.directory).child(templateName + Template.suffix)
        let finalPath = localPath.isDirectory ? localPath : templatePath
        guard finalPath.isDirectory else {
            context.console.error("Invalid template, use the list command to show available options.")
            return
        }
        let output = signature.output ?? currentPath.location
        let outputPath = Path(output)
        guard outputPath.isDirectory else {
            context.console.error("Output path is not a valid directory.")
            return
        }

        let project = currentPath.children()
            .filter { ["xcodeproj", "xcworkspace"].contains($0.extension) }
            .map(\.name)
            .first
        
        let author = try? Git().run(.cmd(.config, "--global user.name"))

        let loadingBar = context.console.customActivity(frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"].map { $0 + " Generating template..."})
        loadingBar.start()
        let template = Template(input: finalPath.location,
                                context: .init(name: signature.name,
                                               project: project ?? signature.name,
                                               author: author ?? "swift-template"))

        try template.generate(output: output)
        loadingBar.succeed()
    }
}
