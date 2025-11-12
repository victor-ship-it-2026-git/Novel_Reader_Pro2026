//
//  GeminiTranslationService.swift
//  Novel Book Reader
//
//  Service for translating text using Google Gemini AI
//

import Foundation
internal import Combine

enum TranslationError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your Gemini API key in Config.swift"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Gemini API."
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError:
            return "Failed to decode translation response."
        }
    }
}

// MARK: - Gemini API Models

struct GeminiRequest: Codable {
    let contents: [Content]

    struct Content: Codable {
        let parts: [Part]

        struct Part: Codable {
            let text: String
        }
    }
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    let error: ErrorInfo?

    struct Candidate: Codable {
        let content: Content

        struct Content: Codable {
            let parts: [Part]

            struct Part: Codable {
                let text: String
            }
        }
    }

    struct ErrorInfo: Codable {
        let message: String
        let code: Int?
    }
}

// MARK: - Translation Service

@MainActor
class GeminiTranslationService: ObservableObject {
    @Published var isTranslating = false
    @Published var errorMessage: String?

    /// Translates text from source language to target language using Google Gemini AI
    /// - Parameters:
    ///   - text: The text to translate
    ///   - sourceLanguage: Source language (default: English)
    ///   - targetLanguage: Target language (default: Burmese)
    /// - Returns: Translated text
    func translate(
        text: String,
        from sourceLanguage: String = Config.sourceLanguage,
        to targetLanguage: String = Config.targetLanguage
    ) async throws -> String {
        // Validate API key
        guard Config.geminiAPIKey != "YOUR_GEMINI_API_KEY_HERE",
              !Config.geminiAPIKey.isEmpty else {
            throw TranslationError.invalidAPIKey
        }

        isTranslating = true
        errorMessage = nil

        // Prepare the prompt
        let prompt = """
        Translate the following text from \(sourceLanguage) to \(targetLanguage).
        Provide only the translation without any explanations or additional text.

        Text to translate:
        \(text)
        """

        // Create request body
        let requestBody = GeminiRequest(
            contents: [
                GeminiRequest.Content(
                    parts: [
                        GeminiRequest.Content.Part(text: prompt)
                    ]
                )
            ]
        )

        // Prepare URL request
        guard let url = URL(string: Config.geminiAPIEndpoint) else {
            throw TranslationError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // Encode request body
            request.httpBody = try JSONEncoder().encode(requestBody)

            // Make the API call
            let (data, response) = try await URLSession.shared.data(for: request)

            // Check HTTP response
            guard response is HTTPURLResponse else {
                throw TranslationError.invalidResponse
            }

            // Decode response
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

            // Check for API errors
            if let error = geminiResponse.error {
                isTranslating = false
                throw TranslationError.apiError(error.message)
            }

            // Extract translated text
            guard let candidate = geminiResponse.candidates?.first,
                  let translatedText = candidate.content.parts.first?.text else {
                throw TranslationError.invalidResponse
            }

            isTranslating = false
            return translatedText.trimmingCharacters(in: .whitespacesAndNewlines)

        } catch let error as TranslationError {
            isTranslating = false
            throw error
        } catch _ as DecodingError {
            isTranslating = false
            throw TranslationError.decodingError
        } catch {
            isTranslating = false
            throw TranslationError.networkError(error)
        }
    }

    /// Fetches web content and translates it
    /// - Parameter urlString: The URL to fetch content from
    /// - Returns: Translated text
    func fetchAndTranslate(urlString: String) async throws -> (original: String, translated: String) {
        let webService = WebContentService()

        // Fetch HTML content
        let htmlContent = try await webService.fetchContent(from: urlString)

        // Extract and limit text
        let extractedText = TextExtractor.extractAndLimitText(from: htmlContent, maxWords: Config.maxWordCount)

        // Translate text
        let translatedText = try await translate(text: extractedText)

        return (original: extractedText, translated: translatedText)
    }
}
