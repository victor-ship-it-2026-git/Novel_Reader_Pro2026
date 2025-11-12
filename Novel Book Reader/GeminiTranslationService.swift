//
//  GeminiTranslationService.swift
//  Novel Book Reader
//
//  Service for translating text using Google Gemini AI
//  Now using official GoogleGenerativeAI SDK
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
        }
    }
}

// MARK: - Translation Service

@MainActor
class GeminiTranslationService: ObservableObject {
   // var objectWillChange: ObservableObjectPublisher
    
    @Published var isTranslating = false
    @Published var errorMessage: String?

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

                   maxOutputTokens: 2048

               ),

               safetySettings: [

                   SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),

                   SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),

                   SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockMediumAndAbove),

                   SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove)

               ]

           )

       }()

    /// Translates text from source language to target language using Google Gemini AI
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

        // Prepare the prompt
        let prompt = """
        Translate the following text from \(sourceLanguage) to \(targetLanguage).
        Provide only the translation without any explanations or additional text.

        Text to translate:
        \(text)
        """

        do {
            // Generate content using the SDK
            let response = try await model.generateContent(prompt)

            // Extract the translated text
            guard let translatedText = response.text else {
                isTranslating = false
                throw TranslationError.noResponse
            }

            isTranslating = false
            return translatedText.trimmingCharacters(in: .whitespacesAndNewlines)

        } catch let error as GenerateContentError {
            isTranslating = false

            // Handle specific SDK errors - FIXED
            switch error {
            case .internalError(let underlying):
                throw TranslationError.networkError(underlying)
            case .promptBlocked(_):
                throw TranslationError.contentBlocked
            case .responseStoppedEarly(let reason, _):  // FIX: Proper tuple handling
                throw TranslationError.apiError("Response stopped early: \(reason). Try shorter text.")
            case .invalidAPIKey(let message):  // FIX: Only one invalidAPIKey case
                throw TranslationError.apiError("Invalid API Key: \(message)")
            case .unsupportedUserLocation:
                throw TranslationError.apiError("Gemini API is not available in your location. Try using a VPN.")
            case .promptImageContentError:
                throw TranslationError.apiError("Image content error (should not occur for text translation)")
            @unknown default:
                throw TranslationError.apiError(error.localizedDescription)
            }
        } catch {
            isTranslating = false
            throw TranslationError.networkError(error)
        }
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
