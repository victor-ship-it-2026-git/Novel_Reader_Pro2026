//
//  GeminiDebugHelper.swift
//  Novel Book Reader
//
//  Created by Win on 12/11/2568 BE.
//


//

//  GeminiDebugHelper.swift

//  Novel Book Reader

//

//  Debug helper for testing Gemini API connection and listing models

//

 

import Foundation

import GoogleGenerativeAI
internal import Combine

 

@MainActor

class GeminiDebugHelper: ObservableObject {
   // var objectWillChange: ObservableObjectPublisher


    @Published var debugLog: String = ""

    @Published var availableModels: [String] = []

    @Published var isLoading = false

 

    /// Test API connection and list available models

    func testConnection(apiKey: String) async {

        guard !apiKey.isEmpty, apiKey != "YOUR_GEMINI_API_KEY_HERE" else {

            appendLog("❌ API Key not configured")

            return

        }

 

        isLoading = true

        appendLog("🔍 Testing API connection...")

        appendLog("API Key: \(apiKey.prefix(10))...")

 

        // Test 1: Try to list models using direct API call

        await listModelsViaAPI(apiKey: apiKey)

 

        // Test 2: Try different model names with the SDK

        await testModelNames(apiKey: apiKey)

 

        isLoading = false

        appendLog("\n✅ Test complete!")

    }

 

    /// List models via direct API call

    private func listModelsViaAPI(apiKey: String) async {

        appendLog("\n📋 Attempting to list models via API...")

 

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models?key=\(apiKey)"

 

        guard let url = URL(string: urlString) else {

            appendLog("❌ Invalid URL")

            return

        }

 

        do {

            let (data, response) = try await URLSession.shared.data(from: url)

 

            if let httpResponse = response as? HTTPURLResponse {

                appendLog("📡 HTTP Status: \(httpResponse.statusCode)")

 

                if (200...299).contains(httpResponse.statusCode) {

                    // Try to parse the response

                    if let jsonString = String(data: data, encoding: .utf8) {

                        appendLog("📦 Response:\n\(jsonString.prefix(500))")

 

                        // Try to extract model names

                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],

                           let models = json["models"] as? [[String: Any]] {

                            appendLog("\n✅ Found \(models.count) models:")

                            for model in models {

                                if let name = model["name"] as? String {

                                    let modelName = name.replacingOccurrences(of: "models/", with: "")

                                    availableModels.append(modelName)

                                    appendLog("  • \(modelName)")

                                }

                            }

                        }

                    }

                } else {

                    // Error response

                    if let errorString = String(data: data, encoding: .utf8) {

                        appendLog("❌ Error Response:\n\(errorString)")

                    }

                }

            }

        } catch {

            appendLog("❌ Network Error: \(error.localizedDescription)")

        }

    }

 

    /// Test different model names

    private func testModelNames(apiKey: String) async {

        appendLog("\n🧪 Testing model names...")

 

        let modelsToTest = [

            "gemini-2.5-flash",

            "gemini-2.0-flash"

        ]

 

        for modelName in modelsToTest {

            await testSingleModel(apiKey: apiKey, modelName: modelName)

        }

    }

 

    /// Test a single model

    private func testSingleModel(apiKey: String, modelName: String) async {

        let model = GenerativeModel(

            name: modelName,

            apiKey: apiKey

        )

 

        do {

            appendLog("\n🔄 Testing: \(modelName)")

            let response = try await model.generateContent("Hello")

 

            if let text = response.text {

                appendLog("✅ \(modelName) - WORKS! Response: \(text.prefix(50))")

            } else {

                appendLog("⚠️ \(modelName) - No text in response")

            }

        } catch {

            appendLog("❌ \(modelName) - Error: \(error.localizedDescription)")

        }

    }

 

    private func appendLog(_ message: String) {

        DispatchQueue.main.async {

            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)

            self.debugLog += "[\(timestamp)] \(message)\n"

            print(message) // Also print to console

        }

    }

 

    func clearLog() {

        debugLog = ""

        availableModels = []

    }

}
