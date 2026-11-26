import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum BF16Error: Error, Equatable {
    case missingAPIKey
    case invalidURL(String)
    case httpError(statusCode: Int, body: String)
}

public struct BF16Message: Codable, Sendable, Equatable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct BF16ChatRequest: Codable, Sendable {
    public let model: String
    public let messages: [BF16Message]
    public let temperature: Double?
    public let maxTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }

    public init(
        model: String,
        messages: [BF16Message],
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
    }
}

public final class BF16Client: @unchecked Sendable {
    public static let defaultBaseURL = "https://api.bf16.ai/v1"
    public static let anthropicBaseURL = "https://api.bf16.ai"

    public static let modelDeepSeekV41Flash = "deepseek/deepseek-v4.1-flash-uncensored"
    public static let modelDeepSeekV41FlashFast = "deepseek/deepseek-v4.1-flash-uncensored-fast"
    public static let modelGLM53Flash = "zai-org/glm-5.3-flash-uncensored"
    public static let modelGLM53 = "zai-org/glm-5.3-uncensored"
    public static let modelKimiK31Pro = "moonshotai/kimi-k3.1-pro-uncensored"
    public static let modelAuto = "bf16/auto"

    public let baseURL: String
    private let apiKey: String?
    private let session: URLSession

    public init(
        apiKey: String? = ProcessInfo.processInfo.environment["BF16_API_KEY"],
        baseURL: String = BF16Client.defaultBaseURL,
        session: URLSession = .shared
    ) {
        if let apiKey, !apiKey.isEmpty {
            self.apiKey = apiKey
        } else {
            self.apiKey = nil
        }
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.session = session
    }

    public func models() async throws -> Data {
        try await request(method: "GET", path: "/models", body: nil, requireAuth: false)
    }

    public func me() async throws -> Data {
        try await request(method: "GET", path: "/me", body: nil, requireAuth: true)
    }

    public func chat(_ payload: BF16ChatRequest) async throws -> Data {
        let encoded = try JSONEncoder().encode(payload)
        return try await request(method: "POST", path: "/chat/completions", body: encoded, requireAuth: true)
    }

    private func request(
        method: String,
        path: String,
        body: Data?,
        requireAuth: Bool
    ) async throws -> Data {
        if requireAuth && apiKey == nil {
            throw BF16Error.missingAPIKey
        }
        let target = "\(baseURL)\(path)"
        guard let url = URL(string: target) else {
            throw BF16Error.invalidURL(target)
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey {
            req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = body
        }

        let (data, response) = try await session.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            throw BF16Error.httpError(
                statusCode: http.statusCode,
                body: String(data: data, encoding: .utf8) ?? ""
            )
        }
        return data
    }
}
