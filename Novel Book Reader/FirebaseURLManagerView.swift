//
//  FirebaseURLManagerView.swift
//  Novel Book Reader
//
//  Manages URLs from Firebase database with extraction and translation
//

import SwiftUI

struct FirebaseURLManagerView: View {
    // MARK: - State Objects
    @StateObject private var firebaseService = FirebaseService()
    @StateObject private var webContentService = WebContentService()
    @StateObject private var translationService = GeminiTranslationService()

    // MARK: - State Properties
    @State private var showAddURLSheet = false
    @State private var selectedURL: NovelURL?
    @State private var extractedContent = ""
    @State private var translatedContent = ""
    @State private var chapterInfo = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var processingURLId: String?

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                if firebaseService.isLoading && firebaseService.novelURLs.isEmpty {
                    ProgressView("Loading URLs from Firebase...")
                } else if firebaseService.novelURLs.isEmpty {
                    emptyStateView
                } else {
                    urlListView
                }
            }
            .navigationTitle("Firebase URLs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddURLSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddURLSheet) {
                AddURLSheet(firebaseService: firebaseService)
            }
            .sheet(item: $selectedURL) { url in
                URLDetailView(
                    novelURL: url,
                    extractedContent: $extractedContent,
                    translatedContent: $translatedContent,
                    chapterInfo: $chapterInfo,
                    webContentService: webContentService,
                    translationService: translationService,
                    firebaseService: firebaseService
                )
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .task {
                do {
                    try await firebaseService.fetchURLs()
                } catch {
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.circle")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("No URLs Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add URLs to Firebase database to extract and translate novel content automatically.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showAddURLSheet = true
            } label: {
                Label("Add Your First URL", systemImage: "plus.circle.fill")
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - URL List View
    private var urlListView: some View {
        List {
            ForEach(firebaseService.novelURLs) { url in
                URLRowView(url: url)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedURL = url
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                try? await firebaseService.deleteURL(id: url.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - URL Row View
struct URLRowView: View {
    let url: NovelURL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = url.title {
                Text(title)
                    .font(.headline)
            }

            Text(url.url)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack {
                statusBadge
                Spacer()
                Text(url.addedDate, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusBadge: some View {
        Text(url.status.rawValue.capitalized)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch url.status {
        case .pending:
            return .orange
        case .processing:
            return .blue
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
}

// MARK: - Add URL Sheet
struct AddURLSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var firebaseService: FirebaseService

    @State private var urlText = ""
    @State private var titleText = ""
    @State private var descriptionText = ""
    @State private var sourceLanguage = "en"
    @State private var targetLanguage = "my"

    var body: some View {
        NavigationStack {
            Form {
                Section("URL Details") {
                    TextField("URL", text: $urlText)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Title (Optional)", text: $titleText)

                    TextField("Description (Optional)", text: $descriptionText)
                }

                Section("Translation Settings") {
                    Picker("Source Language", selection: $sourceLanguage) {
                        Text("English").tag("en")
                        Text("Chinese").tag("zh")
                        Text("Japanese").tag("ja")
                        Text("Korean").tag("ko")
                    }

                    Picker("Target Language", selection: $targetLanguage) {
                        Text("Burmese").tag("my")
                        Text("English").tag("en")
                        Text("Thai").tag("th")
                    }
                }
            }
            .navigationTitle("Add URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addURL()
                    }
                    .disabled(urlText.isEmpty)
                }
            }
        }
    }

    private func addURL() {
        let novelURL = NovelURL(
            url: urlText,
            title: titleText.isEmpty ? nil : titleText,
            description: descriptionText.isEmpty ? nil : descriptionText,
            language: sourceLanguage,
            targetLanguage: targetLanguage
        )

        Task {
            try? await firebaseService.addURL(novelURL)
            dismiss()
        }
    }
}

// MARK: - URL Detail View
struct URLDetailView: View {
    let novelURL: NovelURL
    @Binding var extractedContent: String
    @Binding var translatedContent: String
    @Binding var chapterInfo: String

    @ObservedObject var webContentService: WebContentService
    @ObservedObject var translationService: GeminiTranslationService
    @ObservedObject var firebaseService: FirebaseService

    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // URL Info
                    infoSection

                    // Extract Button
                    if extractedContent.isEmpty {
                        extractButton
                    }

                    // Chapter Info
                    if !chapterInfo.isEmpty {
                        chapterInfoSection
                    }

                    // Extracted Content
                    if !extractedContent.isEmpty {
                        extractedContentSection
                    }

                    // Translate Button
                    if !extractedContent.isEmpty && translatedContent.isEmpty {
                        translateButton
                    }

                    // Translated Content
                    if !translatedContent.isEmpty {
                        translatedContentSection
                    }
                }
                .padding()
            }
            .navigationTitle("Process URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        extractedContent = ""
                        translatedContent = ""
                        chapterInfo = ""
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = novelURL.title {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Text(novelURL.url)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            HStack {
                Label(novelURL.status.rawValue.capitalized, systemImage: "circle.fill")
                    .font(.caption)
                    .foregroundStyle(statusColor)

                Spacer()

                if let sourceLanguage = novelURL.language,
                   let targetLanguage = novelURL.targetLanguage {
                    Text("\(sourceLanguage) → \(targetLanguage)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Extract Button
    private var extractButton: some View {
        Button {
            Task {
                await performExtraction()
            }
        } label: {
            HStack {
                if isProcessing {
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
            .background(isProcessing ? Color.gray : Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(isProcessing)
    }

    // MARK: - Chapter Info Section
    private var chapterInfoSection: some View {
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
    private var extractedContentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Extracted Content")
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
    }

    // MARK: - Translate Button
    private var translateButton: some View {
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
                    Text("Translate to \(novelURL.targetLanguage ?? "my")")
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
    private var translatedContentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Translated Content (\(novelURL.targetLanguage ?? "my"))")
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

    // MARK: - Helper Properties
    private var statusColor: Color {
        switch novelURL.status {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }

    // MARK: - Functions
    private func performExtraction() async {
        isProcessing = true
        chapterInfo = ""
        extractedContent = ""
        translatedContent = ""

        // Update status to processing
        try? await firebaseService.updateURLStatus(id: novelURL.id, status: .processing)

        do {
            // Fetch and parse chapter content
            let chapter = try await webContentService.fetchChapterContent(from: novelURL.url)

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

            isProcessing = false

        } catch {
            isProcessing = false
            try? await firebaseService.updateURLStatus(id: novelURL.id, status: .failed)
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func performTranslation() async {
        guard !extractedContent.isEmpty else { return }

        do {
            let sourceLanguage = novelURL.language ?? "en"
            let targetLanguage = novelURL.targetLanguage ?? "my"

            // Translate the extracted content
            let translated = try await translationService.translate(
                text: extractedContent,
                from: sourceLanguage,
                to: targetLanguage
            )
            translatedContent = translated

            // Update status to completed
            try? await firebaseService.updateURLStatus(id: novelURL.id, status: .completed)

        } catch {
            try? await firebaseService.updateURLStatus(id: novelURL.id, status: .failed)
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
    FirebaseURLManagerView()
}
