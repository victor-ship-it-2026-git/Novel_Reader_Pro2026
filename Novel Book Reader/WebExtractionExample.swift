//
//  WebExtractionExample.swift
//  Novel Book Reader
//
//  Example usage of the web content extraction system
//

import Foundation

// MARK: - Example Usage

/*
 This file demonstrates how to use the enhanced web content extraction system
 for extracting novel chapter content from websites like novelbin.com

 The system includes:
 1. ChapterContent - A structured data model for chapter information
 2. HTMLParser - An advanced HTML parser with configurable rules
 3. ParsingRules - Predefined rules for different novel websites
 4. WebContentService - Service for fetching and parsing web content
 */

// MARK: - Basic Example: Fetching Chapter Content

func exampleFetchChapterContent() async {
    let webService = WebContentService()
    let urlString = "https://novelbin.com/b/i-just-want-to-destroy-the-sect-but-how-did-i-become-a-god-against-all-odds/chapter-269-how-can-the-demonic-sect-be-so-unreasonable"

    do {
        // Fetch and parse chapter content
        let chapter = try await webService.fetchChapterContent(from: urlString)

        // Access structured data
        print("Novel Title: \(chapter.novelTitle ?? "Unknown")")
        print("Chapter Title: \(chapter.chapterTitle)")
        print("Chapter Number: \(chapter.chapterNumber ?? "Unknown")")
        print("Content Preview: \(chapter.contentPreview)")

        // Navigation
        if let nextURL = chapter.nextChapterURL {
            print("Next Chapter: \(nextURL)")
        }

        if let prevURL = chapter.previousChapterURL {
            print("Previous Chapter: \(prevURL)")
        }

    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Example: Fetching and Translating Chapter

func exampleFetchAndTranslateChapter() async {
    let translationService = GeminiTranslationService()
    let urlString = "https://novelbin.com/b/some-novel/chapter-1"

    do {
        // Fetch chapter and translate
        let result = try await translationService.fetchChapterAndTranslate(urlString: urlString)

        // Access chapter data
        let chapter = result.chapter
        let translated = result.translated

        print("Novel: \(chapter.novelTitle ?? "Unknown")")
        print("Chapter: \(chapter.chapterTitle)")
        print("\nOriginal Content (\(wordCount(chapter.content)) words):")
        print(chapter.content)
        print("\nTranslated Content:")
        print(translated)

    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Example: Using Custom Parsing Rules

func exampleCustomParsingRules() async {
    // Define custom rules for a specific website
    let customRules = ParsingRules(
        contentSelectors: ["id=\"my-content\"", "class=\"chapter-text\""],
        titleSelectors: ["class=\"chapter-name\""],
        novelTitleSelectors: ["class=\"book-name\""],
        chapterNumberSelectors: ["class=\"chapter-num\""],
        nextChapterSelectors: ["id=\"next\""],
        previousChapterSelectors: ["id=\"prev\""],
        tagsToRemove: ["script", "style", "nav", "footer"]
    )

    // Create parser with custom rules
    let parser = HTMLParser(rules: customRules)
    let webService = WebContentService(parser: parser)

    do {
        let chapter = try await webService.fetchChapterContent(from: "https://example.com/chapter-1")
        print("Extracted: \(chapter.chapterTitle)")
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Example: Using Predefined Rules

func examplePredefinedRules() async {
    // Use novelbin.com specific rules
    let novelbinParser = HTMLParser(rules: .novelbin)
    let novelbinService = WebContentService(parser: novelbinParser)

    // Use default rules (works with most novel websites)
    let defaultParser = HTMLParser(rules: .default)
    let defaultService = WebContentService(parser: defaultParser)

    // Try both and see which works better
    let urlString = "https://novelbin.com/b/some-novel/chapter-1"

    do {
        print("Trying novelbin-specific rules...")
        let chapter1 = try await novelbinService.fetchChapterContent(from: urlString)
        print("Success with novelbin rules: \(chapter1.chapterTitle)")
    } catch {
        print("Novelbin rules failed: \(error.localizedDescription)")

        do {
            print("Trying default rules...")
            let chapter2 = try await defaultService.fetchChapterContent(from: urlString)
            print("Success with default rules: \(chapter2.chapterTitle)")
        } catch {
            print("Default rules also failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Example: Manual HTML Parsing

func exampleManualParsing() async {
    let webService = WebContentService()
    let urlString = "https://novelbin.com/b/some-novel/chapter-1"

    do {
        // Fetch raw HTML
        let html = try await webService.fetchContent(from: urlString)

        // Parse with custom parser
        let parser = HTMLParser(rules: .novelbin)
        let chapter = parser.parseChapter(from: html)

        print("Chapter Title: \(chapter.chapterTitle)")
        print("Content Length: \(chapter.content.count) characters")
        print("Word Count: \(wordCount(chapter.content)) words")

    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Example: Extracting Only Content (Legacy Method)

func exampleLegacyExtraction() async {
    let webService = WebContentService()
    let urlString = "https://novelbin.com/b/some-novel/chapter-1"

    do {
        // Fetch HTML
        let html = try await webService.fetchContent(from: urlString)

        // Extract text using the simple extractor (gets all text)
        let plainText = TextExtractor.extractText(from: html)

        // Limit to max words
        let limitedText = TextExtractor.limitWords(plainText, to: Config.maxWordCount)

        print("Extracted \(wordCount(limitedText)) words")
        print(limitedText)

    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Helper Functions

private func wordCount(_ text: String) -> Int {
    text.split(separator: " ", omittingEmptySubsequences: true).count
}

// MARK: - Integration with ContentView

/*
 To use the new structured extraction in your ContentView:

 1. Update the performTranslation() method:

    private func performTranslation() async {
        do {
            switch inputMode {
            case .url:
                guard !urlText.isEmpty else { return }

                // Use the new structured extraction
                let result = try await translationService.fetchChapterAndTranslate(urlString: urlText)

                // Display chapter information
                originalText = "[\(result.chapter.novelTitle ?? "")] \(result.chapter.chapterTitle)\n\n\(result.chapter.content)"
                translatedText = result.translated

            case .directText:
                guard !directText.isEmpty else { return }
                let limitedText = TextExtractor.limitWords(directText, to: Config.maxWordCount)
                originalText = limitedText
                let translated = try await translationService.translate(text: limitedText)
                translatedText = translated
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

 2. Or keep using the legacy method (fetchAndTranslate) which still works
 */

// MARK: - Supported Websites

/*
 The system is designed to work with various novel websites. It includes:

 1. Novelbin.com - Specific rules optimized for this site
 2. Default rules - Work with most common novel websites

 Common HTML patterns it looks for:
 - Content: id="chr-content", class="chapter-content", class="reading-content"
 - Title: class="chapter-title", class="chapter-heading"
 - Navigation: id="next_chap", id="prev_chap", rel="next", rel="prev"

 You can add custom rules for any website by creating a new ParsingRules instance.
 */

// MARK: - Troubleshooting

/*
 If extraction doesn't work for a specific website:

 1. Fetch the raw HTML and inspect it:
    let html = try await webService.fetchContent(from: urlString)
    print(html)

 2. Look for the HTML structure and identify:
    - The div/element containing the chapter content
    - The class or id attributes used
    - The chapter title location

 3. Create custom ParsingRules with those selectors:
    let customRules = ParsingRules(
        contentSelectors: ["id=\"the-actual-content-id\""],
        titleSelectors: ["class=\"the-actual-title-class\""],
        ...
    )

 4. For JavaScript-heavy sites (like some novel sites), use the Direct Text input mode
    and manually copy-paste the chapter content instead.
 */
