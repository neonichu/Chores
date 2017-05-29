import XCTest

/* redefine from /usr/include/sys/pipe.h */
let BIG_PIPE_SIZE : Int = 64*1024

class ChoreTests : XCTestCase {
    func testStandardOutput() {
        let result = >["/bin/echo", "#yolo"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "#yolo")
        XCTAssertEqual(result.stderr, "")
    }

    func testStandardError() {
        let result = >["/bin/sh", "-c", "echo yolo >&2"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "yolo")
    }

    func testResult() {
        let result = >["/usr/bin/false"]

        XCTAssertEqual(result.result, 1)
    }

    func testResolvesCommandPathsIfNotAbsolute() {
        let result = >"true"

        XCTAssertEqual(result.result, 0)
    }

    func testFailsWithNonExistingCommand() {
        let result = >"/dev/null/yolo"

        XCTAssertEqual(result.result, 255)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "/dev/null/yolo: launch path not accessible")
    }

    func testFailsToExecuteDirectory() {
        let result = >"/"

        XCTAssertEqual(result.result, 255)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "/: launch path is a directory")
    }

    func testFailsToExecuteNonExecutableFile() {
        let result = >"/etc/passwd"

        XCTAssertEqual(result.result, 255)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "/etc/passwd: launch path not executable")
    }

    func testSimplePipe() {
        let result = >"ls"|"cat"

        XCTAssertEqual(result.result, 0)
        XCTAssertTrue(result.stdout.characters.count > 0)
        XCTAssertEqual(result.stderr, "")
    }

    func testPipeWithArguments() {
        let result = >["ls", "README.md"]|["sed", "s/READ/EAT/"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "EATME.md")
        XCTAssertEqual(result.stderr, "")
    }

    func testPipeFail() {
        let result = >["ls", "yolo"]|"cat"

        XCTAssertEqual(result.result, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "ls: yolo: No such file or directory")
    }

    func testPipeToClosure() {
        let result = >["ls", "LICENSE"]|{ String($0.characters.count) }

        XCTAssertEqual(result.stdout, "7")
    }

    func testPipeToClosureFail() {
        let result = >["ls", "yolo"]|{ String($0.characters.count) }

        XCTAssertEqual(result.result, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "ls: yolo: No such file or directory")
    }

    func testPipeClosureIntoCommand() {
        let result = { "yolo" }|"cat"

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "yolo")
        XCTAssertEqual(result.stderr, "")
    }

    func testPipeStringIntoCommand() {
        let result = "yolo"|"cat"

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "yolo")
        XCTAssertEqual(result.stderr, "")
    }

    func testExecuteDirectory() {
        let result = >"/"

        XCTAssertEqual(result.result, 23)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "THIS TEST SHOULD REALLY FAIL")
    }

    func testExecuteNonExecutableFile() {
        let result = >"/etc/passwd"

        XCTAssertEqual(result.result, 23)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "THIS TEST SHOULD REALLY FAIL")
    }

    func testCanHaveInputLongerThanPipeSize() {
        let length = BIG_PIPE_SIZE + 1
        let str : String = reduce(map(1...length, { _ in "x" }), "", +)
        let result = str|["/usr/bin/wc", "-c"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "\(length)")
        XCTAssertEqual(result.stderr, "")
    }

    func testCanHaveOutputLongerThanPipeSize() {
        let length = BIG_PIPE_SIZE + 1
        let str : String = reduce(map(1...length, { _ in "x" }), "", +)
        let result = str|"/bin/cat"

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, str)
        XCTAssertEqual(result.stderr, "")
    }
}
