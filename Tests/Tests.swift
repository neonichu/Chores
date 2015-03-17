import XCTest

class ChoreTests : XCTestCase {
    func testStandardOutput() {
        let result = §["/bin/echo", "#yolo"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "#yolo")
        XCTAssertEqual(result.stderr, "")
    }

    func testStandardError() {
        let result = §["/bin/sh", "-c", "echo yolo >&2"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "yolo")
    }

    func testResult() {
        let result = §["/usr/bin/false"]

        XCTAssertEqual(result.result, 1)
    }

    func testResolvesCommandPathsIfNotAbsolute() {
        let result = §"true"

        XCTAssertEqual(result.result, 0)
    }
}
