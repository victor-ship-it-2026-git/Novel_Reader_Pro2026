//
//  ContentView.swift
//  Novel Book Reader
//
//  Created by Win on 12/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State Properties

    @StateObject private var translationService = GeminiTranslationService()
    @State private var urlText = ""
    @State private var directText = ""
    @State private var originalText = ""
    @State private var translatedText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var inputMode: InputMode = .url
    @State private var showDebugView = false

    // Sample URL for testing
    private let sampleURL = "https://en.wikipedia.org/wiki/Swift_(programming_language)"

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

                            Text("For sites like novelbin.com that use JavaScript, copy the chapter text and paste it here.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
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
                                Text(inputMode == .url ? "Fetch & Translate" : "Translate")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isInputEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(isInputEmpty || translationService.isTranslating)

                    // MARK: - Original Text Section
                    if !originalText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Original Text (English)")
                                    .font(.headline)
                                Spacer()
                                Text("\(wordCount(originalText)) words")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            ScrollView {
                                Text(originalText)
                                    .font(.body)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .frame(maxHeight: 200)
                        }
                    }

                    // MARK: - Translated Text Section
                    if !translatedText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Translated Text (Burmese)")
                                .font(.headline)

                            ScrollView {
                                Text(translatedText)
                                    .font(.body)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .frame(maxHeight: 200)
                        }
                    }

                    // MARK: - Info Section
                    if originalText.isEmpty && translatedText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(.blue)

                            Text("Enter a URL to get started")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("This app will fetch content from the URL, extract text (up to \(Config.maxWordCount) words), and translate it from English to Burmese using Google Gemini AI.")
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

    private func performTranslation() async {
        do {
            switch inputMode {
            case .url:
                guard !urlText.isEmpty else { return }
                let result = try await translationService.fetchAndTranslate(urlString: urlText)
                originalText = result.original
                translatedText = result.translated

            case .directText:
                guard !directText.isEmpty else { return }
                // Limit the text to configured word count
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

    private func wordCount(_ text: String) -> Int {
        let words = text.split(separator: " ", omittingEmptySubsequences: true)
        return words.count
    }
}

#Preview {
    ContentView()
}
