//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

import Foundation
import ConsoleKit
import PathKit
import SwiftTemplate

final class RemoveCommand: Command {
    
    static let name = "remove"

    let help = "Removes an installed template"
        
    struct Signature: CommandSignature {

        @Argument(name: "name", help: "The name of the template")
        var name: String
    }

    func removeTemplate(at path: Path, using context: CommandContext) throws {
        let yes = context.console.ask("Remove `\(path.location)`? (y/n)".consoleText(.info))
        guard yes == "y" else {
            context.console.warning("Skipping template removal.")
            return
        }
        do {
            try path.delete()
            context.console.success("Template removed.")
        }
        catch {
            context.console.error("Error: \(error.localizedDescription)")
        }
    }

    func run(using context: CommandContext, signature: Signature) throws {
        let templateName = signature.name + Template.suffix
        let globalPath = Path.home.child(Template.directory).child(templateName)
        let localPath = Path.current.child(Template.directory).child(templateName)
        
        var toRemove: [Path] = []
        if localPath.isDirectory {
            toRemove.append(localPath)
        }
        if globalPath.isDirectory {
            toRemove.append(globalPath)
        }
        guard !toRemove.isEmpty else {
            context.console.info("No such template.")
            return
        }
        for path in toRemove {
            try removeTemplate(at: path, using: context)
        }
    }

}
