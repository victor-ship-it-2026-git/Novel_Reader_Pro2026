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
    @State private var originalText = ""
    @State private var translatedText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Sample URL for testing
    private let sampleURL = "https://en.wikipedia.org/wiki/Swift_(programming_language)"

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - URL Input Section
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
                                Text("Fetch & Translate")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(urlText.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(urlText.isEmpty || translationService.isTranslating)

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
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Functions

    private func performTranslation() async {
        guard !urlText.isEmpty else { return }

        do {
            let result = try await translationService.fetchAndTranslate(urlString: urlText)
            originalText = result.original
            translatedText = result.translated
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
