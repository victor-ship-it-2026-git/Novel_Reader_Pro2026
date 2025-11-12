//
//  TextExtractor.swift
//  Novel Book Reader
//
//  Utility for extracting and processing text from HTML content
//

import Foundation

class TextExtractor {
    /// Extracts plain text from HTML content
    /// - Parameter html: The HTML string to extract text from
    /// - Returns: Plain text extracted from HTML
    static func extractText(from html: String) -> String {
        // Remove script and style tags with their content
        var cleanedHTML = html
        cleanedHTML = removeTagsWithContent(cleanedHTML, tags: ["script", "style"])

        // Convert HTML entities
        cleanedHTML = decodeHTMLEntities(cleanedHTML)

        // Remove all HTML tags
        cleanedHTML = removeHTMLTags(cleanedHTML)

        // Clean up whitespace
        cleanedHTML = cleanWhitespace(cleanedHTML)

        return cleanedHTML
    }

    /// Limits text to a specified word count
    /// - Parameters:
    ///   - text: The text to limit
    ///   - maxWords: Maximum number of words
    /// - Returns: Text limited to maxWords
    static func limitWords(_ text: String, to maxWords: Int) -> String {
        let words = text.split(separator: " ", omittingEmptySubsequences: true)

        if words.count <= maxWords {
            return text
        }

        let limitedWords = words.prefix(maxWords)
        return limitedWords.joined(separator: " ")
    }

    /// Extracts and limits text from HTML
    /// - Parameters:
    ///   - html: The HTML string
    ///   - maxWords: Maximum number of words to extract
    /// - Returns: Extracted and limited plain text
    static func extractAndLimitText(from html: String, maxWords: Int = Config.maxWordCount) -> String {
        let plainText = extractText(from: html)
        return limitWords(plainText, to: maxWords)
    }

    // MARK: - Private Helper Methods

    private static func removeTagsWithContent(_ html: String, tags: [String]) -> String {
        var result = html

        for tag in tags {
            let pattern = "<\(tag)[^>]*>.*?</\(tag)>"
            result = result.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }

        return result
    }

    private static func removeHTMLTags(_ html: String) -> String {
        html.replacingOccurrences(
            of: "<[^>]+>",
            with: " ",
            options: .regularExpression
        )
    }

    internal static func decodeHTMLEntities(_ html: String) -> String {
        var result = html

        let entities: [String: String] = [
            "&nbsp;": " ",
            "&lt;": "<",
            "&gt;": ">",
            "&amp;": "&",
            "&quot;": "\"",
            "&apos;": "'",
            "&#39;": "'",
            "&ndash;": "–",
            "&mdash;": "—",
            "&hellip;": "…"
        ]

        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }

        // Handle numeric entities
        let numericPattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: numericPattern, options: []) {
            let nsString = result as NSString
            let matches = regex.matches(in: result, range: NSRange(location: 0, length: nsString.length))

            for match in matches.reversed() {
                if match.numberOfRanges > 1,
                   let range = Range(match.range(at: 1), in: result),
                   let code = Int(result[range]),
                   let scalar = UnicodeScalar(code) {
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: String(Character(scalar)))
                }
            }
        }

        return result
    }

    private static func cleanWhitespace(_ text: String) -> String {
        // Replace multiple whitespace characters with a single space
        let cleaned = text.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )

        // Trim leading and trailing whitespace
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
