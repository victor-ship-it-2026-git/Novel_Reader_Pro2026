//
//  FirebaseService.swift
//  Novel Book Reader
//
//  Service layer for Firebase Realtime Database operations
//

import Foundation
import FirebaseDatabase
import Combine

/// Service for managing novel URLs in Firebase Realtime Database
@MainActor
class FirebaseService: ObservableObject {
    // MARK: - Published Properties
    @Published var novelURLs: [NovelURL] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let database = Database.database()
    private var databaseRef: DatabaseReference {
        database.reference()
    }

    private var urlsRef: DatabaseReference {
        databaseRef.child("novelURLs")
    }

    private var urlsHandle: DatabaseHandle?

    // MARK: - Initialization
    init() {
        setupRealtimeListener()
    }

    deinit {
        removeListener()
    }

    // MARK: - Realtime Listener
    /// Set up realtime listener for URL changes
    private func setupRealtimeListener() {
        urlsHandle = urlsRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }

            Task { @MainActor in
                var urls: [NovelURL] = []

                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any],
                       let novelURL = NovelURL(dictionary: dict) {
                        urls.append(novelURL)
                    }
                }

                // Sort by added date (newest first)
                self.novelURLs = urls.sorted { $0.addedDate > $1.addedDate }
            }
        }
    }

    /// Remove the realtime listener
    private func removeListener() {
        if let handle = urlsHandle {
            urlsRef.removeObserver(withHandle: handle)
        }
    }

    // MARK: - CRUD Operations

    /// Fetch all URLs from Firebase
    func fetchURLs() async throws {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await urlsRef.getData()
            var urls: [NovelURL] = []

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let novelURL = NovelURL(dictionary: dict) {
                    urls.append(novelURL)
                }
            }

            // Sort by added date (newest first)
            self.novelURLs = urls.sorted { $0.addedDate > $1.addedDate }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch URLs: \(error.localizedDescription)"
            throw error
        }
    }

    /// Add a new URL to Firebase
    func addURL(_ novelURL: NovelURL) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await urlsRef.child(novelURL.id).setValue(novelURL.dictionary)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to add URL: \(error.localizedDescription)"
            throw error
        }
    }

    /// Update an existing URL
    func updateURL(_ novelURL: NovelURL) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await urlsRef.child(novelURL.id).updateChildValues(novelURL.dictionary)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to update URL: \(error.localizedDescription)"
            throw error
        }
    }

    /// Update URL status
    func updateURLStatus(id: String, status: NovelURL.ProcessingStatus) async throws {
        do {
            try await urlsRef.child(id).updateChildValues([
                "status": status.rawValue,
                "lastProcessedDate": Date().timeIntervalSince1970
            ])
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
            throw error
        }
    }

    /// Delete a URL from Firebase
    func deleteURL(id: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await urlsRef.child(id).removeValue()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to delete URL: \(error.localizedDescription)"
            throw error
        }
    }

    /// Get pending URLs (not yet processed)
    func getPendingURLs() -> [NovelURL] {
        return novelURLs.filter { $0.status == .pending }
    }

    /// Get a specific URL by ID
    func getURL(by id: String) -> NovelURL? {
        return novelURLs.first { $0.id == id }
    }

    // MARK: - Batch Operations

    /// Add multiple URLs at once
    func addURLs(_ urls: [NovelURL]) async throws {
        isLoading = true
        errorMessage = nil

        do {
            var updates: [String: Any] = [:]
            for url in urls {
                updates["novelURLs/\(url.id)"] = url.dictionary
            }

            try await databaseRef.updateChildValues(updates)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to add URLs: \(error.localizedDescription)"
            throw error
        }
    }

    /// Delete all URLs
    func deleteAllURLs() async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await urlsRef.removeValue()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to delete all URLs: \(error.localizedDescription)"
            throw error
        }
    }
}
