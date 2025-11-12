//
//  ContentView.swift
//  Novel Book Reader
//
//  Created by Win on 12/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State Properties

    @StateObject private var webContentService = WebContentService()
    @StateObject private var translationService = GeminiTranslationService()
    @State private var urlText = ""
    @State private var directText = ""
    @State private var extractedContent = ""
    @State private var translatedContent = ""
    @State private var chapterInfo = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var inputMode: InputMode = .url
    @State private var showDebugView = false
    @State private var isLoading = false

    // Sample URL for testing
    private let sampleURL = "https://novelbin.com/b/i-just-want-to-destroy-the-sect-but-how-did-i-become-a-god-against-all-odds/chapter-269-how-can-the-demonic-sect-be-so-unreasonable"

    enum InputMode {
        case url
        case directText
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Input Mode Picker
                    Picker("Input Mode", selection: $inputMode) {
                        Text("From URL").tag(InputMode.url)
                        Text("Direct Text").tag(InputMode.directText)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 8)

                    // MARK: - URL Input Section
                    if inputMode == .url {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Web URL")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            HStack {
                                TextField("Enter URL", text: $urlText)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.URL)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()

                                Button {
                                    urlText = sampleURL
                                } label: {
                                    Image(systemName: "doc.on.clipboard")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }

                    // MARK: - Direct Text Input Section
                    if inputMode == .directText {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Paste Text Here")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(wordCount(directText)) words")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            TextEditor(text: $directText)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                            Text("For JavaScript-heavy sites, copy the chapter text and paste it here for extraction.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // MARK: - Extract Button
                    Button {
                        Task {
                            await performExtraction()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                Text("Extracting...")
                            } else {
                                Image(systemName: "doc.text.magnifyingglass")
                                Text("Extract Content")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isInputEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(isInputEmpty || isLoading)

                    // MARK: - Chapter Info Section
                    if !chapterInfo.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Chapter Information")
                                .font(.headline)

                            Text(chapterInfo)
                                .font(.subheadline)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    // MARK: - Extracted Content Section
                    if !extractedContent.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Extracted Content (English)")
                                    .font(.headline)
                                Spacer()
                                Text("\(wordCount(extractedContent)) words")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            ScrollView {
                                Text(extractedContent)
                                    .font(.body)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .frame(maxHeight: 300)
                        }

                        // MARK: - Translate Button
                        Button {
                            Task {
                                await performTranslation()
                            }
                        } label: {
                            HStack {
                                if translationService.isTranslating {
                                    ProgressView()
                                        .tint(.white)
                                    Text("Translating...")
                                } else {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("Translate to \(Config.targetLanguage)")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(translationService.isTranslating ? Color.gray : Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(translationService.isTranslating)
                    }

                    // MARK: - Translated Content Section
                    if !translatedContent.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Translated Content (\(Config.targetLanguage))")
                                .font(.headline)

                            ScrollView {
                                Text(translatedContent)
                                    .font(.body)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .frame(maxHeight: 300)
                        }
                    }

                    // MARK: - Info Section
                    if extractedContent.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(.blue)

                            Text("Enter a URL to get started")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("This app will fetch content from novel websites like novelbin.com, extract the chapter content using advanced HTML parsing, and translate it to \(Config.targetLanguage) using Google Gemini AI.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 40)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Novel Reader & Translator")
            .toolbar {

                            ToolbarItem(placement: .navigationBarTrailing) {

                                Button {

                                    showDebugView = true

                                } label: {

                                    Image(systemName: "ant.circle")

                                    Text("Debug")

                                }

                            }

                        }

                        .sheet(isPresented: $showDebugView) {

                            DebugView()

                        }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Computed Properties

    private var isInputEmpty: Bool {
        switch inputMode {
        case .url:
            return urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .directText:
            return directText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - Functions

    private func performExtraction() async {
        isLoading = true
        chapterInfo = ""
        extractedContent = ""
        translatedContent = ""  // Clear translation when extracting new content

        do {
            switch inputMode {
            case .url:
                guard !urlText.isEmpty else {
                    isLoading = false
                    return
                }

                // Fetch and parse chapter content
                let chapter = try await webContentService.fetchChapterContent(from: urlText)

                // Build chapter info
                var info = ""
                if let novelTitle = chapter.novelTitle {
                    info += "📚 Novel: \(novelTitle)\n"
                }
                info += "📖 Chapter: \(chapter.chapterTitle)\n"
                if let chapterNumber = chapter.chapterNumber {
                    info += "🔢 Number: \(chapterNumber)\n"
                }
                if let prevURL = chapter.previousChapterURL {
                    info += "⬅️ Previous: \(prevURL)\n"
                }
                if let nextURL = chapter.nextChapterURL {
                    info += "➡️ Next: \(nextURL)"
                }

                chapterInfo = info.trimmingCharacters(in: .whitespacesAndNewlines)

                // Limit content to max word count
                let limitedContent = TextExtractor.limitWords(chapter.content, to: Config.maxWordCount)
                extractedContent = limitedContent

            case .directText:
                guard !directText.isEmpty else {
                    isLoading = false
                    return
                }
                // For direct text, just limit and display
                let limitedText = TextExtractor.limitWords(directText, to: Config.maxWordCount)
                extractedContent = limitedText
                chapterInfo = "📝 Direct Text Input"
            }

            isLoading = false

        } catch {
            isLoading = false
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func performTranslation() async {
        guard !extractedContent.isEmpty else { return }

        do {
            // Translate the extracted content
            let translated = try await translationService.translate(
                text: extractedContent,
                from: Config.sourceLanguage,
                to: Config.targetLanguage
            )
            translatedContent = translated

        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func wordCount(_ text: String) -> Int {
        let words = text.split(separator: " ", omittingEmptySubsequences: true)
        return words.count
    }
}

#Preview {
    ContentView()
}
