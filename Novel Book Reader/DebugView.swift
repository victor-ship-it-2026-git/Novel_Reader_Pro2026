//
//  DebugView.swift
//  Novel Book Reader
//
//  Created by Win on 12/11/2568 BE.
//


//

//  DebugView.swift

//  Novel Book Reader

//

//  Debug view for testing Gemini API connection

//

 

import SwiftUI

 

struct DebugView: View {

    @StateObject private var debugHelper = GeminiDebugHelper()

    @State private var apiKey: String = Config.geminiAPIKey

 

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 20) {

                    // API Key Input

                    VStack(alignment: .leading, spacing: 8) {

                        Text("API Key")

                            .font(.headline)

 

                        TextField("Enter API Key", text: $apiKey)

                            .textFieldStyle(.roundedBorder)

                            .font(.system(.body, design: .monospaced))

                            .textInputAutocapitalization(.never)

                            .autocorrectionDisabled()

                    }

 

                    // Test Button

                    Button {

                        Task {

                            debugHelper.clearLog()

                            await debugHelper.testConnection(apiKey: apiKey)

                        }

                    } label: {

                        HStack {

                            if debugHelper.isLoading {

                                ProgressView()

                                    .tint(.white)

                                Text("Testing...")

                            } else {

                                Image(systemName: "arrow.triangle.2.circlepath")

                                Text("Test API Connection")

                            }

                        }

                        .frame(maxWidth: .infinity)

                        .padding()

                        .background(Color.blue)

                        .foregroundStyle(.white)

                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    }

                    .disabled(debugHelper.isLoading || apiKey.isEmpty)

 

                    // Available Models

                    if !debugHelper.availableModels.isEmpty {

                        VStack(alignment: .leading, spacing: 8) {

                            Text("Available Models")

                                .font(.headline)

 

                            ForEach(debugHelper.availableModels, id: \.self) { model in

                                HStack {

                                    Image(systemName: "checkmark.circle.fill")

                                        .foregroundStyle(.green)

                                    Text(model)

                                        .font(.system(.body, design: .monospaced))

                                }

                                .padding(.vertical, 4)

                            }

                        }

                        .padding()

                        .background(Color(.systemGray6))

                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    }

 

                    // Debug Log

                    if !debugHelper.debugLog.isEmpty {

                        VStack(alignment: .leading, spacing: 8) {

                            HStack {

                                Text("Debug Log")

                                    .font(.headline)

                                Spacer()

                                Button {

                                    UIPasteboard.general.string = debugHelper.debugLog

                                } label: {

                                    Image(systemName: "doc.on.doc")

                                    Text("Copy")

                                }

                                .font(.caption)

                            }

 

                            ScrollView {

                                Text(debugHelper.debugLog)

                                    .font(.system(.caption, design: .monospaced))

                                    .textSelection(.enabled)

                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }

                            .frame(maxHeight: 400)

                            .padding()

                            .background(Color.black.opacity(0.9))

                            .foregroundStyle(.green)

                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        }

                    }

 

                    // Instructions

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Instructions")

                            .font(.headline)

 
/*
                        Text("""

                        This debug tool will:

                        1. List all available Gemini models for your API key

                        2. Test common model names to see which ones work

                        3. Show detailed API responses

 

                        Use this to diagnose API connection issues.

                        """)*/

                        .font(.caption)

                        .foregroundStyle(.secondary)

                    }

                    .padding()

                    .background(Color(.systemYellow).opacity(0.1))

                    .clipShape(RoundedRectangle(cornerRadius: 10))

 

                    Spacer()

                }

                .padding()

            }

            .navigationTitle("API Debug Tool")

            .navigationBarTitleDisplayMode(.inline)

        }

    }

}

 

#Preview {

    DebugView()

}
