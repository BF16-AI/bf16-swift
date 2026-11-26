import XCTest
@testable import BF16

final class BF16Tests: XCTestCase {
    func testMissingAPIKeyThrows() async {
        let client = BF16Client(apiKey: nil)
        do {
            _ = try await client.me()
            XCTFail("Expected missingAPIKey error")
        } catch let error as BF16Error {
            XCTAssertEqual(error, .missingAPIKey)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testChatRequestEncoding() throws {
        let req = BF16ChatRequest(
            model: BF16Client.modelDeepSeekV41Flash,
            messages: [BF16Message(role: "user", content: "ping")],
            maxTokens: 256
        )
        let data = try JSONEncoder().encode(req)
        let text = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(text.contains("\"max_tokens\":256"))
        XCTAssertTrue(text.contains("deepseek-v4.1-flash-uncensored"))
    }
}
