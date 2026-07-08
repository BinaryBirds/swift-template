import Testing

@testable import SwiftTemplate

#if canImport(FoundationEssentials)
import FoundationEssentials
#if canImport(Foundation)
import Foundation
#endif
#else
import Foundation
#endif
#if canImport(System)
import System
#else
import SystemPackage
#endif

struct SwiftTemplateTests {

    @Test
    func capitalizedFirstCharacter() {
        let name = "myProject"
        #expect(name.capitalizedFirstCharacter == "MyProject")
    }

    @Test
    func contextRendering() throws {
        let inputPath =
            repoRoot
            .appending("Tests")
            .appending("Templates")
            .appending("001")

        let outputPath = FilePath(
            FileManager.default.temporaryDirectory
                .appendingPathComponent(
                    "swift-template-tests-\(UUID().uuidString)"
                )
                .path
        )

        defer {
            try? outputPath.removeIfExists()
        }

        let renderDate = Date(timeIntervalSince1970: 0)
        let template = Template(
            input: inputPath.pathString,
            context: .init(
                name: "test",
                project: "test",
                author: "test author",
                date: renderDate
            )
        )

        try template.generate(output: outputPath.pathString)

        let generatedRoot = outputPath.appending("Test")
        #expect(generatedRoot.isDirectory)
        #expect(try outputPath.visibleChildNames() == ["Test"])

        let resultPath = generatedRoot.appending("test")
        #expect(resultPath.isDirectory)
        #expect(try generatedRoot.visibleChildNames() == ["test"])

        let filePath = resultPath.appending("Test.swift")
        #expect(filePath.isFile)

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateString = formatter.string(from: renderDate)

        let expectedContents = """
            //
            //  TestBuilder.swift
            //  test
            //
            //  Created by test author on \(dateString).
            //

            #if canImport(FoundationEssentials)
            import FoundationEssentials
            #if canImport(Foundation)
            import Foundation
            #endif
            #else
            import Foundation
            #endif

            struct TEST {
                let test: String
            }

            """

        let contents = try String(contentsOf: filePath.fileURL, encoding: .utf8)
        #expect(contents == expectedContents)
    }

    private var repoRoot: FilePath {
        var path = FilePath(#filePath)
        path.removeLastComponent()
        path.removeLastComponent()
        path.removeLastComponent()
        return path
    }
}

extension FilePath {

    fileprivate var pathString: String {
        String(describing: self)
    }

    fileprivate var fileURL: URL {
        URL(fileURLWithPath: pathString)
    }

    fileprivate var isDirectory: Bool {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(
            atPath: pathString,
            isDirectory: &isDirectory
        )
        return exists && isDirectory.boolValue
    }

    fileprivate var isFile: Bool {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(
            atPath: pathString,
            isDirectory: &isDirectory
        )
        return exists && !isDirectory.boolValue
    }

    fileprivate func visibleChildNames() throws -> [String] {
        try FileManager.default
            .contentsOfDirectory(atPath: pathString)
            .filter { !$0.hasPrefix(".") }
            .sorted()
    }

    fileprivate func removeIfExists() throws {
        guard FileManager.default.fileExists(atPath: pathString) else {
            return
        }
        try FileManager.default.removeItem(at: fileURL)
    }
}
