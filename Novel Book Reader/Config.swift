//
//  Config.swift
//  Novel Book Reader
//
//  Configuration file for API keys and settings
//

import Foundation

struct Config {
    // MARK: - Google Gemini AI Configuration

    /// Your Google Gemini API Key
    /// Get your API key from: https://makersuite.google.com/app/apikey
    static let geminiAPIKey = "AIzaSyA65ErT5sEZFyAqwaZcJb8ngNwzWMks6Y0"

    /// Gemini model to use for translation
    /// Options: "gemini-1.5-flash-latest" (faster, cheaper) or "gemini-1.5-pro-latest" (more capable)

      /// Note: Using official GoogleGenerativeAI SDK

      static let geminiModel = "gemini-2.5-flash"

    // MARK: - Translation Settings

    /// Maximum word count for content to translate
    static let maxWordCount = 400

    /// Source language for translation
    static let sourceLanguage = "English"

    /// Target language for translation
    static let targetLanguage = "Burmese"
}

/*
 gemini-2.0-flash
 gemini-2.0-flash-exp
 gemini-2.0-flash-lite
 gemini-2.0-flash-live
 gemini-2.0-flash-preview-image-generation
 gemini-2.5-flash
 gemini-2.5-flash-lite
 gemini-2.5-flash-live
 gemini-2.5-flash-native-audio-dialog
 gemini-2.5-flash-tts
 gemini-2.5-pro
 gemini-robotics-er-1.5-preview
 learnlm-2.0-flash-experimental
 */
