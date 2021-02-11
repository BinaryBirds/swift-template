import XCTest
import PathKit
@testable import SwiftTemplate

final class SwiftTemplateTests: XCTestCase {

    func testExample() throws {
        /// setup work paths
        let baseUrl = "/" + #file.split(separator: "/").dropLast(2).joined(separator: "/")
        let input = baseUrl + "/Example"
        let output = baseUrl + "/Output"
        
        /// cleanup output folder before we start
        try Path(output).delete()
        
        /// create and generate the template with a given test context
        let template = Template(input: input, context: .init(module: "Test", project: "test", author: "test author"))
        try template.generate(output: output)

        /// cleanup output folder
//        try Path(output).delete()
    }
}
