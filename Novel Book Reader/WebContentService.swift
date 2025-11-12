//
//  WebContentService.swift
//  Novel Book Reader
//
//  Service for fetching web content
//

import Foundation

enum WebContentError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingError:
            return "Failed to decode response data."
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
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WebContentError.invalidResponse
            }

            guard let htmlString = String(data: data, encoding: .utf8) else {
                throw WebContentError.decodingError
            }

            isLoading = false
            return htmlString

        } catch {
            isLoading = false
            throw WebContentError.networkError(error)
        }
    }
}
