import XCTest
@testable import HTTPRequestsManager

final class HTTPRequestsManagerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HTTPRequestsManager().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
