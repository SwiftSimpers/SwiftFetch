import Swifter
@testable import SwiftFetch
import XCTest

func startHttpServer() throws -> HttpServer {
    let server = HttpServer()

    server["/"] = { req in
        if let test = req.headers["test"] {
            return HttpResponse.ok(.text(test))
        } else {
            return HttpResponse.ok(.text("Hello World!"))
        }
    }
    server["/json"] = { _ in
        HttpResponse.ok(.text("{ \"test\": \"naisu\"}"))
    }

    try server.start(6969)
    return server
}

final class SwiftFetchTests: XCTestCase {
    func testReadingText() async throws {
        let server = try startHttpServer()

        let res = try await fetch("http://localhost:6969")

        XCTAssertEqual(res.status, 200)
        XCTAssertTrue(res.ok)

        let text = try await res.text()
        XCTAssertEqual(text, "Hello World!")

        XCTAssertEqual(res.headers.get("content-length"), "12")

        server.stop()
    }
    
    func testReadingJSON() async throws {
        let server = try startHttpServer()
        
        let res = try await fetch("http://localhost:6969/json")
        
        XCTAssertEqual(res.status, 200)
        XCTAssertTrue(res.ok)
        
        let json = try await res.json()
        XCTAssertEqual(json as! [String: String], ["test": "naisu"])
        
        server.stop()
    }
    
    func testReadingTextWithHeader() async throws {
        let server = try startHttpServer()

        let res = try await fetch("http://localhost:6969", FetchRequestInit(headers: ["test": "test"]))

        XCTAssertEqual(res.status, 200)
        XCTAssertTrue(res.ok)

        let text = try await res.text()
        XCTAssertEqual(text, "test")

        XCTAssertEqual(res.headers.get("content-length"), "12")

        server.stop()
    }
}
