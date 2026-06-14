import Foundation

public enum UploadError: Error, Sendable {
    case failed(statusCode: Int)
    case missingSignedURL
}

public struct SignedMediaUpload: Codable, Sendable {
    public let artifact_id: UUID
    public let upload_url: URL
    public let thumb_upload_url: URL?
    public let source_path: String
    public let thumbnail_path: String?
}

public protocol MediaUploadService: Sendable {
    func uploadFile(to url: URL, data: Data, contentType: String) async throws
}

public final class URLSessionMediaUploadService: MediaUploadService, Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func uploadFile(to url: URL, data: Data, contentType: String) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let (_, response) = try await session.upload(for: request, from: data)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw UploadError.failed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }
}
