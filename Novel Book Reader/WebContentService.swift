//
//  WebContentService.swift
//  Novel Book Reader
//
//  Service for fetching web content
//

import Foundation
internal import Combine

enum WebContentError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(statusCode: Int)
    case decodingError
    case noResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Invalid response from server (Status code: \(statusCode)). The website may be blocking automated requests."
        case .decodingError:
            return "Failed to decode response data."
        case .noResponse:
            return "No response received from server."
        }
    }
}

@MainActor
class WebContentService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Fetches HTML content from a given URL
    /// - Parameter urlString: The URL string to fetch content from
    /// - Returns: The HTML content as a string
    func fetchContent(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw WebContentError.invalidURL
        }

        isLoading = true
        errorMessage = nil

        do {
            // Configure URLRequest with proper headers
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 30

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                isLoading = false
                throw WebContentError.noResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                isLoading = false
                throw WebContentError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            guard let htmlString = String(data: data, encoding: .utf8) else {
                isLoading = false
                throw WebContentError.decodingError
            }

            isLoading = false
            return htmlString

        } catch let error as WebContentError {
            isLoading = false
            throw error
        } catch {
            isLoading = false
            throw WebContentError.networkError(error)
        }
    }
}
