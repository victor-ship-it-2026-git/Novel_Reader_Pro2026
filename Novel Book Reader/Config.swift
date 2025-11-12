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
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY_HERE"

    // MARK: - Translation Settings

    /// Maximum word count for content to translate
    static let maxWordCount = 400

    /// Source language for translation
    static let sourceLanguage = "English"

    /// Target language for translation
    static let targetLanguage = "Burmese"

    // MARK: - API Endpoints

    /// Gemini API endpoint for content generation
    static var geminiAPIEndpoint: String {
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(geminiAPIKey)"
    }
}
