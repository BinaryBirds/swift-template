//
//  SwiftTemplateTests.swift
//  SwiftTemplateTests
//
//  Created by Tibor Bodecs on 2020. 04. 19..
//

import XCTest
import PathKit
@testable import SwiftTemplate

final class SwiftTemplateTests: XCTestCase {

    var baseUrl: String { "/" + #file.split(separator: "/").dropLast(2).joined(separator: "/") }
 
    // MARK: - test cases
    
    func testCapitalizedFirstCharacter() throws {
        let name = "myProject"
        XCTAssertEqual(name.capitalizedFirstCharacter, "MyProject")
    }
    
    // TC: 001
    func testContextRendering() throws {
        /// setup work paths
        let input = baseUrl + "/Templates/001"
        let output = baseUrl + "/Results/001"

        /// cleanup output folder before we start
        try Path(output).delete()
        
        /// create and generate the template with a given test context
        let template = Template(input: input, context: .init(name: "test", project: "test", author: "test author"))
        try template.generate(output: output)

        let outputPath = Path(output)
        
        /// check if template was created
        XCTAssertEqual(outputPath.children().map(\.name), ["Test"])

        /// check if test directory was created inside the result project with the right name
        let resultPath = outputPath.child("test")
        XCTAssertTrue(resultPath.isDirectory)
        XCTAssertEqual(resultPath.children().map(\.name), ["test"])

        /// check if template file was created with the right name
        let filePath = resultPath.child("test").child("Test.swift")
        XCTAssertTrue(filePath.isFile)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateString = formatter.string(from: Date())

        let expectedContents = """
        //
        //  TestBuilder.swift
        //  test
        //
        //  Created by test author on \(dateString).
        //

        import Foundation

        struct TEST {
            let test: String
        }

        """
        
        let contents = try String(contentsOf: filePath.url)
        
        /// check if the context variables were properly replaced in the template file
        XCTAssertEqual(contents, expectedContents)
        
        /// cleanup output folder
        try Path(output).delete()
    }
}
