import Foundation

/// The result of a task execution
public typealias ChoreResult = (result: Int32, stdout: String, stderr: String)

private func string_trim(string: NSString!) -> String {
    return string.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet()) ?? ""
}

private func chore_task(command: String, _ arguments: [String] = [String](), stdin: String = "") -> ChoreResult {
    let task = NSTask()

    task.launchPath = command
    task.arguments = arguments

    if !(task.launchPath as NSString).absolutePath {
        task.launchPath = (chore_task("/usr/bin/which", [task.launchPath])).stdout
    }

    var isDirectory: ObjCBool = false

    if !NSFileManager.defaultManager().fileExistsAtPath(task.launchPath, isDirectory: &isDirectory) {
        return (255, "", String(format: "%@: launch path not accessible", task.launchPath))
    }

    if (isDirectory) {
        return (255, "", String(format: "%@: launch path is a directory", task.launchPath))
    }

    if !NSFileManager.defaultManager().isExecutableFileAtPath(task.launchPath) {
        return (255, "", String(format: "%@: launch path not executable", task.launchPath))
    }

    if count(stdin) > 0 {
        let stdinPipe = NSPipe()
        task.standardInput = stdinPipe
        let stdinHandle = stdinPipe.fileHandleForWriting

        if let data = stdin.dataUsingEncoding(NSUTF8StringEncoding) {
            stdinHandle.writeData(data)
            stdinHandle.closeFile()
        }
    }

    let stderrPipe = NSPipe()
    task.standardError = stderrPipe
    let stderrHandle = stderrPipe.fileHandleForReading

    let stdoutPipe = NSPipe()
    task.standardOutput = stdoutPipe
    let stdoutHandle = stdoutPipe.fileHandleForReading

    task.launch()
    task.waitUntilExit()

    let stderr = string_trim(NSString(data: stderrHandle.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)) ?? ""
    let stdout = string_trim(NSString(data: stdoutHandle.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)) ?? ""

    return (task.terminationStatus, stdout, stderr)
}

prefix operator > {}

/**
Executes a command.

:param: command The command to execute.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public prefix func > (command: String) -> ChoreResult {
    return chore_task(command)
}

/**
Executes a command with arguments.

:param: command The command to execute and its arguments.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public prefix func > (command: [String]) -> ChoreResult {
    switch command.count {
        case 0:
            return (0, "", "")
        case 1:
            return chore_task(command[0])
        default:
            break
    }

    return chore_task(command[0], Array(command[1..<command.count]))
}

infix operator | {}

/**
Executes a command with standard input from another command.

:param: left The result of a previous command.
:param: right The command to execute.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public func | (left: ChoreResult, right: String) -> ChoreResult {
    return left|[right]
}

/**
Executes a command with standard input from another command.

:param: left The result of a previous command.
:param: right The command to execute and its arguments.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public func | (left: ChoreResult, right: [String]) -> ChoreResult {
    if left.result != 0 {
        return left
    }

    let arguments = right.count >= 2 ? Array(right[1..<right.count]) : [String]()
    return chore_task(right[0], arguments, stdin: left.stdout)
}

/**
Executes a closure with input from a previous command.

:param: left The result of a previous command.
:param: right The closure to execute.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public func | (left: ChoreResult, right: ((String) -> String)) -> ChoreResult {
    if left.result != 0 {
        return left
    }

    return (0, right(left.stdout), "")
}

/**
Executes a command with input from a closure.

:param: left The closure to execute.
:param: right The command to execute.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public func | (left: (() -> String), right: String) -> ChoreResult {
    return (0, left(), "")|right
}

/**
Executes a command with input from a closure.

:param: left The closure to execute.
:param: right The command to execute and its arguments.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public func | (left: (() -> String), right: [String]) -> ChoreResult {
    return (0, left(), "")|right
}

/**
Executes a command with input from a string.

:param: left The string to use a stdin.
:param: right The command to execute.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public func | (left: String, right: String) -> ChoreResult {
    return (0, left, "")|right
}

/**
Executes a command with input from a string.

:param: left The string to use a stdin.
:param: right The command to execute and its arguments.
:returns: A tuple containing the exit code, stdout and stderr output.
*/
public func | (left: String, right: [String]) -> ChoreResult {
    return (0, left, "")|right
}
