import Foundation

public enum APIError: Error, Equatable, Sendable {
    case network(String)
    case decoding(String)
    case server(code: String, message: String)
    case unauthorized
    case invalidResponse
    case unknown
}

public struct APIConfiguration: Sendable {
    public let baseURL: URL
    public let appVersion: String
    public let platform: String

    public init(baseURL: URL, appVersion: String = "1.0.0", platform: String = "ios") {
        self.baseURL = baseURL
        self.appVersion = appVersion
        self.platform = platform
    }
}

public protocol AccessTokenProviding: Sendable {
    func accessToken() async throws -> String
}

public struct ClosureTokenProvider: AccessTokenProviding {
    private let closure: @Sendable () async throws -> String

    public init(_ closure: @escaping @Sendable () async throws -> String) {
        self.closure = closure
    }

    public func accessToken() async throws -> String {
        try await closure()
    }
}

private struct ServerErrorEnvelope: Decodable {
    struct ServerError: Decodable {
        let code: String
        let message: String
    }
    let error: ServerError
}

public final class APIClient: Sendable {
    private let configuration: APIConfiguration
    private let tokenProvider: AccessTokenProviding
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(configuration: APIConfiguration, tokenProvider: AccessTokenProviding, session: URLSession = .shared) {
        self.configuration = configuration
        self.tokenProvider = tokenProvider
        self.session = session
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func request<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: Body? = nil
    ) async throws -> Response {
        var components = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components?.url else { throw APIError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.appVersion, forHTTPHeaderField: "X-App-Version")
        request.setValue(configuration.platform, forHTTPHeaderField: "X-App-Platform")
        let token = try await tokenProvider.accessToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            if http.statusCode == 401 { throw APIError.unauthorized }
            guard (200..<300).contains(http.statusCode) else {
                if let envelope = try? decoder.decode(ServerErrorEnvelope.self, from: data) {
                    throw APIError.server(code: envelope.error.code, message: envelope.error.message)
                }
                throw APIError.invalidResponse
            }
            if Response.self == EmptyResponse.self, data.isEmpty {
                return EmptyResponse() as! Response
            }
            return try decoder.decode(Response.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decoding(String(describing: error))
        } catch {
            throw APIError.network(error.localizedDescription)
        }
    }
}

public struct EmptyRequest: Encodable, Sendable { public init() {} }
public struct EmptyResponse: Decodable, Sendable { public init() {} }
