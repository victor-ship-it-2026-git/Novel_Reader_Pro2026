//
//  HTMLParser.swift
//  Novel Book Reader
//
//  Advanced HTML parser for extracting novel chapter content
//

import Foundation

/// Configuration for parsing HTML from different novel websites
struct ParsingRules {
    /// Patterns to identify chapter content containers
    let contentSelectors: [String]

    /// Patterns to identify chapter title
    let titleSelectors: [String]

    /// Patterns to identify novel title
    let novelTitleSelectors: [String]

    /// Patterns to identify chapter number
    let chapterNumberSelectors: [String]

    /// Patterns for next chapter link
    let nextChapterSelectors: [String]

    /// Patterns for previous chapter link
    let previousChapterSelectors: [String]

    /// Tags to remove completely (with their content)
    let tagsToRemove: [String]

    /// Default parsing rules for common novel websites
    static let `default` = ParsingRules(
        contentSelectors: [
            "id=\"chr-content\"",
            "class=\"chapter-content\"",
            "class=\"chapter_content\"",
            "class=\"entry-content\"",
            "class=\"text_story\"",
            "class=\"content-area\"",
            "id=\"chapter-content\"",
            "class=\"reading-content\"",
            "id=\"chaptercontent\""
        ],
        titleSelectors: [
            "class=\"chapter-title\"",
            "class=\"chapter_title\"",
            "class=\"title_chapter\"",
            "class=\"entry-title\"",
            "class=\"chapter-heading\"",
            "id=\"chapter-heading\""
        ],
        novelTitleSelectors: [
            "class=\"novel-title\"",
            "class=\"novel_title\"",
            "class=\"book-title\"",
            "class=\"series-title\"",
            "property=\"og:title\""
        ],
        chapterNumberSelectors: [
            "class=\"chapter-number\"",
            "class=\"chapter_number\"",
            "data-chapter"
        ],
        nextChapterSelectors: [
            "id=\"next_chap\"",
            "class=\"next-chapter\"",
            "class=\"next_chapter\"",
            "rel=\"next\"",
            "data-next"
        ],
        previousChapterSelectors: [
            "id=\"prev_chap\"",
            "class=\"prev-chapter\"",
            "class=\"previous-chapter\"",
            "rel=\"prev\"",
            "data-prev"
        ],
        tagsToRemove: ["script", "style", "nav", "header", "footer", "aside", "iframe"]
    )

    /// Parsing rules specifically for novelbin.com
    static let novelbin = ParsingRules(
        contentSelectors: [
            "id=\"chr-content\"",
            "class=\"chapter-content\"",
            "class=\"reading-content\"",
            "id=\"chapter-content\""
        ],
        titleSelectors: [
            "class=\"chapter-title\"",
            "class=\"chr-title\"",
            "class=\"chapter-heading\""
        ],
        novelTitleSelectors: [
            "class=\"novel-title\"",
            "class=\"book-name\"",
            "property=\"og:title\""
        ],
        chapterNumberSelectors: [
            "class=\"chapter-number\"",
            "data-chapter-id\""
        ],
        nextChapterSelectors: [
            "id=\"next_chap\"",
            "class=\"next-chapter\"",
            "data-next-id\""
        ],
        previousChapterSelectors: [
            "id=\"prev_chap\"",
            "class=\"prev-chapter\"",
            "data-prev-id\""
        ],
        tagsToRemove: ["script", "style", "nav", "header", "footer", "aside", "iframe", "ins"]
    )
}

class HTMLParser {
    private let rules: ParsingRules

    /// Initialize parser with specific rules
    /// - Parameter rules: Parsing rules to use
    init(rules: ParsingRules = .default) {
        self.rules = rules
    }

    /// Parses HTML and extracts chapter content
    /// - Parameter html: Raw HTML string
    /// - Returns: Structured chapter content
    func parseChapter(from html: String) -> ChapterContent {
        var cleanedHTML = html

        // Remove unwanted tags
        cleanedHTML = removeTagsWithContent(cleanedHTML, tags: rules.tagsToRemove)

        // Extract components
        let novelTitle = extractNovelTitle(from: html)
        let chapterTitle = extractChapterTitle(from: html)
        let chapterNumber = extractChapterNumber(from: html)
        let content = extractContent(from: cleanedHTML)
        let nextChapterURL = extractNextChapterURL(from: html)
        let previousChapterURL = extractPreviousChapterURL(from: html)

        return ChapterContent(
            novelTitle: novelTitle,
            chapterTitle: chapterTitle ?? "Chapter",
            chapterNumber: chapterNumber,
            content: content,
            previousChapterURL: previousChapterURL,
            nextChapterURL: nextChapterURL
        )
    }

    // MARK: - Private Extraction Methods

    private func extractNovelTitle(from html: String) -> String? {
        for selector in rules.novelTitleSelectors {
            if let title = extractTextFromSelector(html, selector: selector) {
                return cleanText(title)
            }
        }
        return nil
    }

    private func extractChapterTitle(from html: String) -> String? {
        for selector in rules.titleSelectors {
            if let title = extractTextFromSelector(html, selector: selector) {
                return cleanText(title)
            }
        }

        // Fallback: Try to find h1, h2, or h3 with "chapter" in the text
        if let title = extractTextMatching(html, pattern: "<h[123][^>]*>[^<]*[Cc]hapter[^<]*</h[123]>") {
            return cleanText(title)
        }

        return nil
    }

    private func extractChapterNumber(from html: String) -> String? {
        for selector in rules.chapterNumberSelectors {
            if let number = extractTextFromSelector(html, selector: selector) {
                return cleanText(number)
            }
        }

        // Try to extract chapter number from title
        if let title = extractChapterTitle(from: html) {
            let pattern = "[Cc]hapter[\\s-]*(\\d+)"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let nsString = title as NSString
                if let match = regex.firstMatch(in: title, range: NSRange(location: 0, length: nsString.length)),
                   match.numberOfRanges > 1,
                   let range = Range(match.range(at: 1), in: title) {
                    return String(title[range])
                }
            }
        }

        return nil
    }

    private func extractContent(from html: String) -> String {
        // First, try a simpler direct extraction for common patterns
        if let content = extractContentByID(html, id: "chr-content") {
            let cleaned = cleanText(content)
            if cleaned.count > 100 {
                return cleaned
            }
        }

        // Try each content selector using the complex method
        for selector in rules.contentSelectors {
            if let content = extractTextFromSelector(html, selector: selector) {
                let cleaned = cleanText(content)
                // Only return if we got substantial content (more than 100 characters)
                if cleaned.count > 100 {
                    return cleaned
                }
            }
        }

        // Fallback: Extract all text from body
        return extractAllText(from: html)
    }

    /// Simple extraction by ID - extracts content within a tag with specific ID
    private func extractContentByID(_ html: String, id: String) -> String? {
        // Simple approach: Find the id attribute and extract a large chunk
        // Then rely on cleanText to remove all HTML tags
        let patterns = [
            "id\\s*=\\s*\"\(id)\"",
            "id\\s*=\\s*'\(id)'"
        ]

        for pattern in patterns {
            if let range = html.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                // Find the > after the id to get the start of content
                let afterID = html[range.upperBound...]
                if let contentStart = afterID.firstIndex(of: ">") {
                    let contentStartIndex = html.index(after: contentStart)
                    // Take a large chunk (next 50000 characters or to end)
                    let endIndex = html.index(contentStartIndex, offsetBy: min(50000, html.distance(from: contentStartIndex, to: html.endIndex)))
                    let chunk = String(html[contentStartIndex..<endIndex])

                    // Return the chunk - cleanText will handle removing tags
                    return chunk
                }
            }
        }

        return nil
    }

    private func extractNextChapterURL(from html: String) -> String? {
        for selector in rules.nextChapterSelectors {
            if let url = extractURLFromSelector(html, selector: selector) {
                return url
            }
        }
        return nil
    }

    private func extractPreviousChapterURL(from html: String) -> String? {
        for selector in rules.previousChapterSelectors {
            if let url = extractURLFromSelector(html, selector: selector) {
                return url
            }
        }
        return nil
    }

    // MARK: - Helper Methods

    private func extractTextFromSelector(_ html: String, selector: String) -> String? {
        // Find the opening tag with the selector
        guard let startRange = html.range(of: selector, options: .caseInsensitive) else {
            return nil
        }

        // Find the start of the tag
        let searchStart = html[..<startRange.lowerBound]
        guard let tagStartRange = searchStart.lastIndex(of: "<") else {
            return nil
        }

        // Extract tag name
        let afterTag = html[startRange.lowerBound...]
        guard let tagEndIndex = afterTag.firstIndex(of: ">") else {
            return nil
        }

        let fullTagStart = html[tagStartRange..<startRange.lowerBound]
        let tagName = extractTagName(from: String(fullTagStart))

        // Find the closing tag
        let afterTagEnd = html[html.index(after: tagEndIndex)...]
        let closingTag = "</\(tagName)>"

        guard let closingRange = afterTagEnd.range(of: closingTag, options: .caseInsensitive) else {
            return nil
        }

        // Extract content between tags
        let content = String(afterTagEnd[..<closingRange.lowerBound])
        return content
    }

    private func extractURLFromSelector(_ html: String, selector: String) -> String? {
        guard let startRange = html.range(of: selector, options: .caseInsensitive) else {
            return nil
        }

        // Search backwards to find the opening <a tag
        let searchStart = html[..<startRange.upperBound]
        guard let aTagStart = searchStart.range(of: "<a[^>]*", options: [.regularExpression, .caseInsensitive, .backwards]) else {
            return nil
        }

        // Extract the href attribute
        let tagContent = String(html[aTagStart.lowerBound..<startRange.upperBound])
        return extractHrefAttribute(from: tagContent)
    }

    private func extractHrefAttribute(from tag: String) -> String? {
        let pattern = "href\\s*=\\s*[\"']([^\"']+)[\"']"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let nsString = tag as NSString
        guard let match = regex.firstMatch(in: tag, range: NSRange(location: 0, length: nsString.length)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: tag) else {
            return nil
        }

        return String(tag[range])
    }

    private func extractTagName(from tagStart: String) -> String {
        let cleaned = tagStart.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = cleaned.split(separator: " ")
        return String(components.first ?? "div").replacingOccurrences(of: "<", with: "")
    }

    private func extractTextMatching(_ html: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let nsString = html as NSString
        guard let match = regex.firstMatch(in: html, range: NSRange(location: 0, length: nsString.length)),
              let range = Range(match.range, in: html) else {
            return nil
        }

        return String(html[range])
    }

    private func extractAllText(from html: String) -> String {
        // Remove all HTML tags
        let withoutTags = html.replacingOccurrences(
            of: "<[^>]+>",
            with: " ",
            options: .regularExpression
        )

        return cleanText(withoutTags)
    }

    private func removeTagsWithContent(_ html: String, tags: [String]) -> String {
        var result = html

        for tag in tags {
            // Handle multi-line tags with dotAll option
            let pattern = "<\(tag)[^>]*>.*?</\(tag)>"
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                let nsString = result as NSString
                result = regex.stringByReplacingMatches(in: result, range: NSRange(location: 0, length: nsString.length), withTemplate: "")
            }
        }

        return result
    }

    private func cleanText(_ text: String) -> String {
        var cleaned = text

        // First, remove problematic tags with their content (ads, scripts, etc.)
        let tagsToStrip = ["script", "style", "noscript", "iframe", "ins", "aside", "nav", "header", "footer", "form"]
        for tag in tagsToStrip {
            if let regex = try? NSRegularExpression(pattern: "<\(tag)[^>]*>.*?</\(tag)>", options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                let nsString = cleaned as NSString
                cleaned = regex.stringByReplacingMatches(in: cleaned, range: NSRange(location: 0, length: nsString.length), withTemplate: "")
            }
        }

        // Remove HTML comments
        if let regex = try? NSRegularExpression(pattern: "<!--.*?-->", options: [.dotMatchesLineSeparators]) {
            let nsString = cleaned as NSString
            cleaned = regex.stringByReplacingMatches(in: cleaned, range: NSRange(location: 0, length: nsString.length), withTemplate: "")
        }

        // Replace paragraph tags with newlines for better formatting
        // This preserves the paragraph structure
        let paragraphTags = ["</p>", "</P>", "<p>", "<P>", "<br>", "<BR>", "<br/>", "<BR/>", "<br />", "<BR />"]
        for tag in paragraphTags {
            cleaned = cleaned.replacingOccurrences(of: tag, with: "\n\n", options: .caseInsensitive)
        }

        // Also handle <p ...> tags with attributes
        if let regex = try? NSRegularExpression(pattern: "<p[^>]*>", options: .caseInsensitive) {
            let nsString = cleaned as NSString
            cleaned = regex.stringByReplacingMatches(in: cleaned, range: NSRange(location: 0, length: nsString.length), withTemplate: "\n\n")
        }

        // Remove all remaining HTML tags - apply multiple passes to catch edge cases
        for _ in 0..<3 {  // Apply 3 times to handle nested or malformed tags
            if let regex = try? NSRegularExpression(pattern: "<[^>]*>", options: [.dotMatchesLineSeparators]) {
                let nsString = cleaned as NSString
                let before = cleaned
                cleaned = regex.stringByReplacingMatches(in: cleaned, range: NSRange(location: 0, length: nsString.length), withTemplate: " ")
                // If nothing changed, we're done
                if before == cleaned {
                    break
                }
            }
        }

        // Decode HTML entities
        cleaned = TextExtractor.decodeHTMLEntities(cleaned)

        // Remove any remaining < or > characters that might be left
        cleaned = cleaned.replacingOccurrences(of: "<", with: "")
        cleaned = cleaned.replacingOccurrences(of: ">", with: "")

        // Clean up multiple spaces and tabs (but preserve newlines for paragraphs)
        cleaned = cleaned.replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)

        // Reduce multiple consecutive newlines to maximum of 2 (one blank line between paragraphs)
        cleaned = cleaned.replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)

        // Trim leading and trailing whitespace from each line
        let lines = cleaned.components(separatedBy: "\n")
        let trimmedLines = lines.map { $0.trimmingCharacters(in: .whitespaces) }
        cleaned = trimmedLines.joined(separator: "\n")

        // Trim leading and trailing whitespace from the entire text
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
