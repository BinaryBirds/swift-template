//
//  InstallCommand.swift
//  SwiftTemplateCli
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

import Foundation
import ConsoleKit
import GitKit
import PathKit
import SwiftTemplate

final class InstallCommand: Command {
    
    static let name = "install"

    let help = "Install a new template from a given git repository."
        
    struct Signature: CommandSignature {

        @Argument(name: "url", help: "The url of the template repository")
        var url: String
        
        @Flag(name: "global", short: "g", help: "Template name to use")
        var global: Bool
    }

    func run(using context: CommandContext, signature: Signature) throws {
        let loadingBar = context.console.customActivity(frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"].map { $0 + " Installing template..."})
        var path = Path.current.child(Template.directory)
        if signature.global {
            path = Path.home.child(Template.directory)
        }
        let git = Git(path: path.location)
        do {
            loadingBar.start()
            try git.run(.clone(url: signature.url))
            loadingBar.succeed()
            let name = URL(string: signature.url)?.lastPathComponent.replacingOccurrences(of: Template.suffix, with: "") ?? "unknown"
            context.console.info("Template `\(name)` installed to: \(path.location)")
        }
        catch {
            loadingBar.fail()
            context.console.error("Error: \(error.localizedDescription)")
        }
    }
}
