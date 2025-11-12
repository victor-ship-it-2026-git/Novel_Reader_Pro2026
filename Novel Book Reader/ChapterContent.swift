//
//  ChapterContent.swift
//  Novel Book Reader
//
//  Data model for novel chapter content
//

import Foundation

/// Represents the structured content of a novel chapter
struct ChapterContent {
    /// The title of the novel/book
    let novelTitle: String?

    /// The chapter title
    let chapterTitle: String

    /// The chapter number (if available)
    let chapterNumber: String?

    /// The main chapter content/text
    let content: String

    /// URL to the previous chapter (if available)
    let previousChapterURL: String?

    /// URL to the next chapter (if available)
    let nextChapterURL: String?

    /// Any additional metadata
    let metadata: [String: String]

    /// Returns the full chapter text (title + content)
    var fullText: String {
        var text = ""

        if let novelTitle = novelTitle {
            text += "\(novelTitle)\n\n"
        }

        text += "\(chapterTitle)\n\n"
        text += content

        return text
    }

    /// Returns a preview of the content (first 200 characters)
    var contentPreview: String {
        if content.count > 200 {
            return String(content.prefix(200)) + "..."
        }
        return content
    }

    /// Initializer with default values
    init(
        novelTitle: String? = nil,
        chapterTitle: String,
        chapterNumber: String? = nil,
        content: String,
        previousChapterURL: String? = nil,
        nextChapterURL: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.novelTitle = novelTitle
        self.chapterTitle = chapterTitle
        self.chapterNumber = chapterNumber
        self.content = content
        self.previousChapterURL = previousChapterURL
        self.nextChapterURL = nextChapterURL
        self.metadata = metadata
    }
}

// MARK: - Equatable
extension ChapterContent: Equatable {
    static func == (lhs: ChapterContent, rhs: ChapterContent) -> Bool {
        lhs.novelTitle == rhs.novelTitle &&
        lhs.chapterTitle == rhs.chapterTitle &&
        lhs.chapterNumber == rhs.chapterNumber &&
        lhs.content == rhs.content
    }
}
