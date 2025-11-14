//
//  GeminiTranslationService.swift
//  Novel Book Reader
//
//  Service for translating text using Google Gemini AI
//  Now using official GoogleGenerativeAI SDK with exponential backoff retry
//

import Foundation
import GoogleGenerativeAI
internal import Combine

enum TranslationError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case contentBlocked
    case noResponse
    case maxRetriesExceeded

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
        case .contentBlocked:
            return "Content was blocked by safety filters. Try different text."
        case .noResponse:
            return "No response received from Gemini API."
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded. The service may be temporarily unavailable."
        }
    }
}

// MARK: - Translation Service

@MainActor
class GeminiTranslationService: ObservableObject {
   // var objectWillChange: ObservableObjectPublisher

    @Published var isTranslating = false
    @Published var errorMessage: String?
    @Published var retryAttempt: Int = 0
    @Published var retryMessage: String?

    private lazy var model: GenerativeModel? = {

           // Validate API key

           guard Config.geminiAPIKey != "YOUR_GEMINI_API_KEY_HERE",

                 !Config.geminiAPIKey.isEmpty else {

               return nil

           }



           // Initialize the Gemini model

           return GenerativeModel(

               name: Config.geminiModel,

               apiKey: Config.geminiAPIKey,

               generationConfig: GenerationConfig(

                   temperature: 0.3,  // Lower temperature for more consistent translations

                   topP: 0.95,

                   topK: 40,

                   maxOutputTokens: 4096  // Increased for longer translations

               ),

               safetySettings: [

                   // Using blockOnlyHigh to reduce false positives for novel content
                   SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh),

                   SafetySetting(harmCategory: .hateSpeech, threshold: .blockOnlyHigh),

                   SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockOnlyHigh),

                   SafetySetting(harmCategory: .dangerousContent, threshold: .blockOnlyHigh)

               ]

           )

       }()

    /// Translates text from source language to target language using Google Gemini AI with automatic retry
    /// - Parameters:
    ///   - text: The text to translate
    ///   - sourceLanguage: Source language (default: English)
    ///   - targetLanguage: Target language (default: Burmese)
    /// - Returns: Translated text
    func translate(
        text: String,
        from sourceLanguage: String = "English",  // Direct default values
        to targetLanguage: String = "Burmese"     // Direct default values
    ) async throws -> String {
        // Validate model is initialized
        guard let model = model else {
            throw TranslationError.invalidAPIKey
        }

        isTranslating = true
        errorMessage = nil
        retryAttempt = 0
        retryMessage = nil

        // Sanitize the input text to avoid API issues
        let sanitizedText = sanitizeTextForTranslation(text)

        // Debug logging
        #if DEBUG
        print("🔤 Translation Request:")
        print("  - Text length: \(sanitizedText.count) characters")
        print("  - Word count: \(sanitizedText.split(separator: " ").count) words")
        print("  - First 100 chars: \(String(sanitizedText.prefix(100)))")
        #endif

        // Prepare the prompt with clearer instructions
        let prompt = """
        Translate the following text from \(sourceLanguage) to \(targetLanguage).
        Important:
        - Provide ONLY the translated text
        - Do NOT include any explanations, notes, or additional commentary
        - Preserve the paragraph structure and line breaks

        Text to translate:
        \(sanitizedText)
        """

        #if DEBUG
        print("  - Total prompt length: \(prompt.count) characters")
        print("  - Estimated tokens: ~\(prompt.count / 4)")
        #endif

        // Try with exponential backoff
        var lastError: Error?
        var delay = Config.initialRetryDelay

        for attempt in 0...Config.maxRetryAttempts {
            do {
                if attempt > 0 {
                    retryAttempt = attempt
                    retryMessage = "Retrying... (Attempt \(attempt)/\(Config.maxRetryAttempts))"

                    #if DEBUG
                    print("🔄 Retry attempt \(attempt)/\(Config.maxRetryAttempts) after \(delay)s delay")
                    #endif

                    // Wait before retrying with exponential backoff
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }

                #if DEBUG
                print("  - Sending request to model: \(Config.geminiModel)")
                #endif

                // Generate content using the SDK
                let response = try await model.generateContent(prompt)

                #if DEBUG
                print("✅ Translation successful\(attempt > 0 ? " (after \(attempt) retries)" : "")")
                #endif

                // Extract the translated text
                guard let translatedText = response.text else {
                    throw TranslationError.noResponse
                }

                // Success - reset retry state
                isTranslating = false
                retryAttempt = 0
                retryMessage = nil

                return translatedText.trimmingCharacters(in: .whitespacesAndNewlines)

            } catch let error as GenerateContentError {
                lastError = error

                #if DEBUG
                print("❌ GenerateContentError: \(error)")
                print("  Full error description: \(error.localizedDescription)")
                #endif

                // Check if this error is retryable
                let isRetryable = isRetryableError(error)

                #if DEBUG
                print("  Is retryable: \(isRetryable)")
                print("  Current attempt: \(attempt)/\(Config.maxRetryAttempts)")
                #endif

                // Handle specific SDK errors
                switch error {
                case .internalError(let underlying):
                    #if DEBUG
                    print("  Internal error type: \(type(of: underlying))")
                    print("  Internal error: \(underlying)")
                    print("  Internal error description: \(underlying.localizedDescription)")

                    // Parse error details from string representation
                    let errorString = String(describing: underlying)
                    if errorString.contains("httpResponseCode:") {
                        print("  Error string contains HTTP response code")
                        print("  Full error string: \(errorString)")
                    }
                    #endif

                    // Check for 503 error or network issues
                    if isRetryable && attempt < Config.maxRetryAttempts {
                        #if DEBUG
                        print("  → Retryable error detected, will retry")
                        #endif
                        delay *= 2  // Exponential backoff
                        continue
                    } else if attempt >= Config.maxRetryAttempts {
                        #if DEBUG
                        print("  → Max retries reached, giving up")
                        #endif
                    } else {
                        #if DEBUG
                        print("  → Non-retryable error")
                        #endif
                    }

                    // Check if it's a decoding error (malformed content)
                    if let decodingError = underlying as? DecodingError {
                        isTranslating = false
                        retryAttempt = 0
                        retryMessage = nil
                        throw TranslationError.apiError("Content may be blocked by safety filters or API returned malformed response. Try with shorter text or different content.")
                    }

                    isTranslating = false
                    retryAttempt = 0
                    retryMessage = nil
                    throw TranslationError.networkError(underlying)

                case .promptBlocked(let response):
                    #if DEBUG
                    print("  Prompt blocked: \(response)")
                    #endif
                    isTranslating = false
                    retryAttempt = 0
                    retryMessage = nil
                    throw TranslationError.contentBlocked

                case .responseStoppedEarly(let reason, let response):  // FIX: Proper tuple handling
                    #if DEBUG
                    print("  Response stopped early: \(reason), response: \(response)")
                    #endif
                    isTranslating = false
                    retryAttempt = 0
                    retryMessage = nil
                    throw TranslationError.apiError("Response stopped early: \(reason). Try shorter text.")

                case .invalidAPIKey(let message):  // FIX: Only one invalidAPIKey case
                    isTranslating = false
                    retryAttempt = 0
                    retryMessage = nil
                    throw TranslationError.apiError("Invalid API Key: \(message)")

                case .unsupportedUserLocation:
                    isTranslating = false
                    retryAttempt = 0
                    retryMessage = nil
                    throw TranslationError.apiError("Gemini API is not available in your location. Try using a VPN.")

                case .promptImageContentError:
                    isTranslating = false
                    retryAttempt = 0
                    retryMessage = nil
                    throw TranslationError.apiError("Image content error (should not occur for text translation)")

                @unknown default:
                    #if DEBUG
                    print("  Unknown error: \(error)")
                    #endif

                    // Retry unknown errors if under max attempts
                    if isRetryable && attempt < Config.maxRetryAttempts {
                        delay *= 2
                        continue
                    }

                    isTranslating = false
                    retryAttempt = 0
                    retryMessage = nil
                    throw TranslationError.apiError(error.localizedDescription)
                }
            } catch let error as DecodingError {
                // Catch decoding errors specifically - don't retry these
                isTranslating = false
                retryAttempt = 0
                retryMessage = nil

                #if DEBUG
                print("❌ DecodingError: \(error)")
                #endif
                throw TranslationError.apiError("API response format error. The content may be blocked by safety filters or the text is too long. Try shorter text.")
            } catch {
                lastError = error

                #if DEBUG
                print("❌ Unknown error: \(error)")
                #endif

                // Retry network errors
                if attempt < Config.maxRetryAttempts {
                    delay *= 2
                    continue
                }
            }
        }

        // Max retries exceeded
        isTranslating = false
        retryAttempt = 0
        retryMessage = nil

        #if DEBUG
        print("❌ Max retries exceeded")
        #endif

        if let lastError = lastError {
            throw TranslationError.networkError(lastError)
        } else {
            throw TranslationError.maxRetriesExceeded
        }
    }

    /// Determines if an error should be retried
    /// - Parameter error: The error to check
    /// - Returns: True if the error is transient and should be retried
    private func isRetryableError(_ error: GenerateContentError) -> Bool {
        switch error {
        case .internalError(let underlying):
            // Check for specific HTTP status codes that indicate temporary issues
            let errorString = String(describing: underlying)

            // 503 - Service Unavailable / Overloaded
            if errorString.contains("503") || errorString.contains("overloaded") {
                return true
            }

            // 429 - Too Many Requests / Rate Limited
            if errorString.contains("429") || errorString.contains("rate limit") {
                return true
            }

            // 500 - Internal Server Error
            if errorString.contains("500") {
                return true
            }

            // Generic network errors
            if errorString.contains("timeout") || errorString.contains("connection") {
                return true
            }

            return false

        default:
            // Don't retry content blocked, invalid API key, etc.
            return false
        }
    }

    /// Sanitizes text before sending to translation API
    /// - Parameter text: The text to sanitize
    /// - Returns: Sanitized text safe for API transmission
    private func sanitizeTextForTranslation(_ text: String) -> String {
        var sanitized = text

        // Ensure consistent line breaks (use \n only)
        sanitized = sanitized.replacingOccurrences(of: "\r\n", with: "\n")
        sanitized = sanitized.replacingOccurrences(of: "\r", with: "\n")

        // Remove any potentially problematic characters
        sanitized = sanitized.trimmingCharacters(in: .controlCharacters)

        return sanitized
    }

    /// Fetches chapter content and translates it (structured extraction)
    /// - Parameter urlString: The URL to fetch content from
    /// - Returns: Original chapter content and translated text
    func fetchChapterAndTranslate(urlString: String) async throws -> (chapter: ChapterContent, translated: String) {
        let webService = WebContentService()

        // Fetch and parse chapter content
        let chapter = try await webService.fetchChapterContent(from: urlString)

        // Limit the content to max word count
        let limitedContent = TextExtractor.limitWords(chapter.content, to: Config.maxWordCount)

        // Validate extracted text
        guard !limitedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TranslationError.apiError("No text content could be extracted from the URL. The page may be empty or require JavaScript.")
        }

        guard limitedContent.split(separator: " ").count >= 5 else {
            throw TranslationError.apiError("Insufficient text extracted from URL (less than 5 words). Try a different URL or copy the text directly.")
        }

        // Translate text
        let translatedText = try await translate(text: limitedContent)

        // Return chapter with limited content and translation
        let limitedChapter = ChapterContent(
            novelTitle: chapter.novelTitle,
            chapterTitle: chapter.chapterTitle,
            chapterNumber: chapter.chapterNumber,
            content: limitedContent,
            previousChapterURL: chapter.previousChapterURL,
            nextChapterURL: chapter.nextChapterURL,
            metadata: chapter.metadata
        )

        return (chapter: limitedChapter, translated: translatedText)
    }

    /// Fetches web content and translates it (legacy method)
    /// - Parameter urlString: The URL to fetch content from
    /// - Returns: Translated text
    func fetchAndTranslate(urlString: String) async throws -> (original: String, translated: String) {
        let webService = WebContentService()

        // Fetch HTML content
        let htmlContent = try await webService.fetchContent(from: urlString)

        // Extract and limit text
        let extractedText = TextExtractor.extractAndLimitText(from: htmlContent, maxWords: Config.maxWordCount)

        // Validate extracted text
        guard !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TranslationError.apiError("No text content could be extracted from the URL. The page may be empty or require JavaScript.")
        }

        guard extractedText.split(separator: " ").count >= 5 else {
            throw TranslationError.apiError("Insufficient text extracted from URL (less than 5 words). Try a different URL.")
        }

        // Translate text
        let translatedText = try await translate(text: extractedText)

        return (original: extractedText, translated: translatedText)
    }
}
