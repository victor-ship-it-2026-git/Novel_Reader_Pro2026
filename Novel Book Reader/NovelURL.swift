//
//  NovelURL.swift
//  Novel Book Reader
//
//  Data model for novel URLs stored in Firebase
//

import Foundation

/// Represents a novel URL stored in Firebase database
struct NovelURL: Identifiable, Codable {
    var id: String
    let url: String
    let title: String?
    let description: String?
    let language: String? // Source language
    let targetLanguage: String? // Target translation language
    let addedDate: Date
    let lastProcessedDate: Date?
    let status: ProcessingStatus

    enum ProcessingStatus: String, Codable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case title
        case description
        case language
        case targetLanguage
        case addedDate
        case lastProcessedDate
        case status
    }

    init(id: String = UUID().uuidString,
         url: String,
         title: String? = nil,
         description: String? = nil,
         language: String? = "en",
         targetLanguage: String? = "my",
         addedDate: Date = Date(),
         lastProcessedDate: Date? = nil,
         status: ProcessingStatus = .pending) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
        self.language = language
        self.targetLanguage = targetLanguage
        self.addedDate = addedDate
        self.lastProcessedDate = lastProcessedDate
        self.status = status
    }
}

/// Extension for Firebase conversion
extension NovelURL {
    /// Convert to Firebase dictionary
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "url": url,
            "addedDate": addedDate.timeIntervalSince1970,
            "status": status.rawValue
        ]

        if let title = title { dict["title"] = title }
        if let description = description { dict["description"] = description }
        if let language = language { dict["language"] = language }
        if let targetLanguage = targetLanguage { dict["targetLanguage"] = targetLanguage }
        if let lastProcessedDate = lastProcessedDate {
            dict["lastProcessedDate"] = lastProcessedDate.timeIntervalSince1970
        }

        return dict
    }

    /// Create from Firebase dictionary
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let url = dictionary["url"] as? String,
              let statusString = dictionary["status"] as? String,
              let status = ProcessingStatus(rawValue: statusString),
              let addedDateTimestamp = dictionary["addedDate"] as? TimeInterval else {
            return nil
        }

        self.id = id
        self.url = url
        self.title = dictionary["title"] as? String
        self.description = dictionary["description"] as? String
        self.language = dictionary["language"] as? String
        self.targetLanguage = dictionary["targetLanguage"] as? String
        self.addedDate = Date(timeIntervalSince1970: addedDateTimestamp)
        self.status = status

        if let lastProcessedTimestamp = dictionary["lastProcessedDate"] as? TimeInterval {
            self.lastProcessedDate = Date(timeIntervalSince1970: lastProcessedTimestamp)
        } else {
            self.lastProcessedDate = nil
        }
    }
}
