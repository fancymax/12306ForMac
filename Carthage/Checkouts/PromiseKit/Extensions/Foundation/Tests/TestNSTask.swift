import PMKFoundation
import Foundation
import PromiseKit
import XCTest

#if os(macOS)

class NSTaskTests: XCTestCase {
    func test1() {
        let ex = expectation(description: "")
        let task = Process()
        task.launchPath = "/usr/bin/basename"
        task.arguments = ["/foo/doe/bar"]
        task.promise().asStandardOutput(encoding: .utf8).then { stdout -> Void in
            XCTAssertEqual(stdout, "bar\n")
            ex.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

    func test2() {
        let ex = expectation(description: "")
        let dir = "PMKAbsentDirectory"

        let task = Process()
        task.launchPath = "/bin/ls"
        task.arguments = [dir]

        task.promise().then { _ -> Void in
            XCTFail()
        }.catch { err in
            if let err = err as? Process.Error, err.code == .execution {
                let expectedStderrData = "ls: \(dir): No such file or directory\n".data(using: .utf8, allowLossyConversion: false)!

                XCTAssertEqual(err.stderr, expectedStderrData)
                XCTAssertEqual(err.exitStatus, 1)
                XCTAssertEqual(err.stdout.count, 0)
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }
}

#endif
