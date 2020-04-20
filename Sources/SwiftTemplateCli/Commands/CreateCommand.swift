//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

import Foundation
import ConsoleKit
import GitKit
import PathKit
import ShellKit
import SwiftTemplate

final class CreateCommand: Command {
    
    static let name = "create"

    let help = "Create a new Swift template"
        
    struct Signature: CommandSignature {

        @Argument(name: "name", help: "The name of the template")
        var name: String
        
        @Flag(name: "global", short: "g", help: "Template name to use")
        var global: Bool
    }

    func run(using context: CommandContext, signature: Signature) throws {
        var path = Path.current.child(Template.directory)
        if signature.global {
            path = Path.home.child(Template.directory)
        }
        let templatePath = path.child(signature.name + Template.suffix)
        print(templatePath.location)
        let git = Git(path: templatePath.location)
        let sh = Shell()
        do {
            let readme = """
            \"# \(signature.name)\"

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

            try git.run(.cmd(.initialize))
            try sh.run("cd \(templatePath.location) && echo \"README.md\" > \(Template.ignoreFile)")
            try sh.run("cd \(templatePath.location) && echo \"\(readme)\" > README.md")
            
            context.console.info("Template ready at: \(templatePath.location)")
            #if os(macOS)
            try sh.run("open -a Finder \(templatePath.location)")
            #endif
        }
        catch {
            context.console.error(error.localizedDescription)
        }
    }
}
