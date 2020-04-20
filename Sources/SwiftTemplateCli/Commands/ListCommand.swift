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

final class ListCommand: Command {
    
    static let name = "list"

    let help = "List installed templates"
        
    struct Signature: CommandSignature {}

    func printTemplates(context: CommandContext, at path: Path, style: ConsoleStyle, flag: String = "") {
        for path in path.children().filter(\.isDirectory).filter(\.isVisible) {
            let name = path.name.replacingOccurrences(of: Template.suffix, with: "")
            context.console.output(name + " \(flag)", style: style)
        }
    }

    func run(using context: CommandContext, signature: Signature) throws {
        let workPath = Path.home.child(Template.directory)
        let localPath = Path.current.child(Template.directory)
        self.printTemplates(context: context, at: localPath, style: .success)
        self.printTemplates(context: context, at: workPath, style: .info, flag: "(global)")
    }
}
