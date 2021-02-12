//
//  UpdateCommand.swift
//  SwiftTemplateCli
//
//  Created by Tibor Bodecs on 2020. 04. 20..
//

import Foundation
import ConsoleKit
import PathKit
import GitKit
import SwiftTemplate

final class UpdateCommand: Command {
    
    static let name = "update"

    let help = "Update installed templates"
        
    struct Signature: CommandSignature {}

    func run(using context: CommandContext, signature: Signature) throws {
        let workPath = Path.home.child(Template.directory)
        let localPath = Path.current.child(Template.directory)
        let templates = localPath.children() + workPath.children()
        let loadingBar = context.console.customActivity(frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"].map { $0 + " Updating templates..."})
        loadingBar.start()
        for path in templates.filter(\.isDirectory).filter(\.isVisible) {
            let git = Git(path: path.location)
            do {
                try git.run(.cmd(.pull))
                loadingBar.succeed()
                let name = path.url.lastPathComponent.replacingOccurrences(of: Template.suffix, with: "")
                context.console.info("Template `\(name)` updated.")
            }
            catch {
                loadingBar.fail()
                context.console.error("Error: \(error.localizedDescription)")
            }
        }
    }
}
