# Novel Reader Pro - English to Burmese Translator

An iOS app built with Swift and SwiftUI that fetches content from web URLs and translates it from English to Burmese using Google Gemini AI.

**Now using the official GoogleGenerativeAI SDK for better reliability and error handling!**

## Features

- 📱 **iOS 18.6+ Compatible**: Built with the latest Swift and iOS technologies
- 🌐 **Dual Input Modes**:
  - **URL Mode**: Automatically fetches and extracts text from web URLs
  - **Direct Text Mode**: Paste text directly (perfect for JavaScript-heavy novel sites)
- 🔤 **Smart Text Extraction**: Removes HTML tags and extracts clean, readable text
- 🌍 **AI-Powered Translation**: Uses Google Gemini AI for accurate English to Burmese translation
- ⚡ **Real-time Processing**: Async/await based for smooth, non-blocking UI
- 📊 **Word Count Limiting**: Configurable word limit (currently 400 words) to manage API usage
- 🎨 **Modern SwiftUI Interface**: Clean, intuitive user interface with segmented controls
- 📖 **Novel-Friendly**: Works with novelbin.com, wuxiaworld, and other reading sites via direct text mode
- 🔧 **Built-in Debug Tools**: Comprehensive API debugging tools to diagnose connection issues and discover available models

## Project Structure

```
Novel Book Reader/
├── Novel_Book_ReaderApp.swift      # Main app entry point
├── ContentView.swift                # Main UI view with translation interface
├── Config.swift                     # Configuration file for API keys and settings
├── WebContentService.swift          # Service for fetching web content
├── TextExtractor.swift              # Utility for extracting text from HTML
├── GeminiTranslationService.swift   # Google Gemini AI translation service
├── GeminiDebugHelper.swift          # Debug helper for API diagnostics
└── DebugView.swift                  # Debug UI for testing API connection
```

## Requirements

- **Xcode**: 15.0 or later
- **iOS Deployment Target**: iOS 18.6+
- **Swift**: 6.0+
- **Google Gemini API Key**: Required (free tier available)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd Novel_Reader_Pro2026
```

### 2. Add GoogleGenerativeAI SDK

**IMPORTANT**: You must add the official Google SDK as a Swift Package dependency.

1. Open the project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the package URL: `https://github.com/google/generative-ai-swift`
4. Select "Up to Next Major Version" (0.5.4 or latest)
5. Click "Add Package"
6. Select "GoogleGenerativeAI" and click "Add Package"

**📖 Detailed instructions**: [ADDING_GOOGLE_SDK.md](ADDING_GOOGLE_SDK.md)

### 3. Get Your Google Gemini API Key

Follow the detailed instructions in [GOOGLE_GEMINI_SETUP_GUIDE.md](GOOGLE_GEMINI_SETUP_GUIDE.md) to:
- Create a Google Cloud account
- Get your Gemini API key
- Configure API restrictions (optional but recommended)

### 4. Configure Your API Key

1. Open the project in Xcode
2. Navigate to `Novel Book Reader/Config.swift`
3. Replace `"YOUR_GEMINI_API_KEY_HERE"` with your actual API key:

```swift
static let geminiAPIKey = "AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 5. Build and Run

1. Select a simulator or connect your iOS device
2. Press ⌘ + R or click the Run button
3. The app will build and launch

## Usage

The app supports two input methods:

### Method 1: From URL (Recommended for simple websites)

1. **Select "From URL" mode** (default)
2. **Enter a URL**: Type or paste a web URL in the text field
   - Or click the clipboard icon to use the sample Wikipedia URL
3. **Fetch & Translate**: Tap the "Fetch & Translate" button
   - The app will fetch the web content
   - Extract the first 400 words of text
   - Translate from English to Burmese

**Best for**: Wikipedia, blogs, news articles, static HTML pages

### Method 2: Direct Text Input (For JavaScript-heavy sites)

1. **Select "Direct Text" mode**
2. **Paste your text**: Copy chapter content from websites and paste it into the text field
3. **Translate**: Tap the "Translate" button
   - The app will limit the text to 400 words
   - Translate from English to Burmese

**Best for**: Novel reading sites (novelbin.com, wuxiaworld, etc.), paywalled content, JavaScript-rendered pages

### View Results

- **Original Text**: Shows the extracted/pasted English text
- **Translated Text**: Shows the Burmese translation
- **Word Count**: Displays the number of words processed

### Using the Debug Tool 🔧

If you encounter API connection issues or want to verify your setup:

1. **Open Debug Tool**: Tap the wrench icon (🔧) in the top-right corner
2. **Verify API Key**: The tool will show your configured API key
3. **Test Connection**: Tap "Test API Connection"
4. **View Results**:
   - **Available Models**: Lists all Gemini models accessible with your API key
   - **Debug Log**: Shows detailed API responses and test results
   - **Copy Log**: Tap "Copy" to copy the debug log for troubleshooting

**The debug tool will:**
- List all available Gemini models for your API key
- Test common model names (gemini-pro, gemini-1.5-pro, gemini-1.5-flash, etc.)
- Show detailed API responses and error messages
- Help diagnose 404 errors and API configuration issues

**💡 Tip**: Run the debug tool first if you encounter any API errors!

## Configuration Options

Edit `Config.swift` to customize:

```swift
// Maximum word count for translation
static let maxWordCount = 400  // Change this value

// Languages
static let sourceLanguage = "English"
static let targetLanguage = "Burmese"
```

## Architecture

### Services

- **WebContentService**: Handles HTTP requests to fetch web content
- **GeminiTranslationService**: Manages communication with Google Gemini AI using official SDK
- **TextExtractor**: Processes HTML and extracts plain text

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Async/Await**: For asynchronous network operations
- **Combine**: For reactive state management
- **URLSession**: For network requests
- **GoogleGenerativeAI SDK**: Official Google SDK for Gemini AI integration
- **Google Gemini 1.5 Flash**: AI model for fast, efficient translation

## API Usage and Limits

### Free Tier Limits
- **15 requests per minute** (free tier)
- **1,500 requests per day**
- **1 million tokens per minute**

### Cost Optimization
- Text is limited to 400 words by default to reduce token usage
- Adjust `Config.maxWordCount` to increase or decrease the limit

## Security Notes

⚠️ **Important**:
- Never commit your API key to version control
- `Config.swift` is added to `.gitignore` to prevent accidental commits
- For production apps, consider using a backend server to handle API calls

## Troubleshooting

### 🔧 Step 1: Use the Debug Tool First!

Before troubleshooting, **always run the debug tool** to diagnose issues:

1. Tap the wrench icon (🔧) in the top-right corner
2. Tap "Test API Connection"
3. Review the debug log to identify the specific issue:
   - **No models listed**: API key issue or API not enabled
   - **404 errors for all models**: Generative Language API not enabled in Google Cloud
   - **403 errors**: API key restrictions or quota exceeded
   - **401 errors**: Invalid API key

The debug tool will show you **exactly** what's wrong and which models are available.

### ⚠️ Network Error: "Invalid Response from Server"

This is the most common issue. It usually means network permissions are not configured. **Follow these steps**:

1. **Configure Network Permissions in Xcode**
   - Open your project in Xcode
   - Select the target → Info tab
   - Add "App Transport Security Settings" dictionary
   - Add "Allow Arbitrary Loads" = YES

   **📖 See detailed instructions**: [XCODE_CONFIGURATION_GUIDE.md](XCODE_CONFIGURATION_GUIDE.md)

2. **Verify Your API Key**
   - Open `Config.swift`
   - Replace `"YOUR_GEMINI_API_KEY_HERE"` with your actual API key
   - Get your key from: https://makersuite.google.com/app/apikey

3. **Test with the Debug Tool**
   - Use the debug tool (🔧 icon) to verify your API key works
   - Check which models are available

4. **Test with Sample URL**
   - Use the clipboard icon to load the Wikipedia sample URL
   - Click "Fetch & Translate"

### Other Common Issues

1. **"models/gemini-pro is not found" or "404 error"**
   - **Use the Debug Tool**: Run the debug tool (🔧) to see which models are available
   - The debug tool will list all accessible models for your API key
   - Update `Config.swift` with a working model name from the debug tool results
   - If no models are listed, you may need to enable the Generative Language API in Google Cloud Console
   - Clean and rebuild: ⌘ + Shift + K, then ⌘ + B

2. **"Invalid API key" error**
   - **Use the Debug Tool**: The debug tool will verify if your API key is valid
   - Double-check your API key in `Config.swift`
   - Ensure there are no extra spaces or characters
   - Verify the key starts with "AIzaSy"

3. **"Network error: The resource could not be loaded"**
   - This means App Transport Security is blocking requests
   - Follow the configuration guide: [XCODE_CONFIGURATION_GUIDE.md](XCODE_CONFIGURATION_GUIDE.md)

4. **HTTP Status Code 403 or 401**
   - 403: Website is blocking automated requests or API key restricted
   - 401: API key is missing or invalid
   - Try a different URL (e.g., Wikipedia pages work well)

5. **"No text content could be extracted"**
   - The webpage may require JavaScript to load content
   - **Solution**: Use the "Direct Text" input mode
     1. Switch to "Direct Text" mode using the segmented control
     2. Open the webpage in your browser
     3. Copy the chapter/article text
     4. Paste it into the text field
     5. Click "Translate"
   - This works great for novel sites like novelbin.com, wuxiaworld, etc.

6. **Empty or strange translation**
   - Verify the extracted text makes sense (check Original Text section)
   - Some websites have anti-scraping protection
   - Try different URLs or use the "Direct Text" mode

### Getting More Help

- **Network & Xcode Setup**: [XCODE_CONFIGURATION_GUIDE.md](XCODE_CONFIGURATION_GUIDE.md)
- **API Setup**: [GOOGLE_GEMINI_SETUP_GUIDE.md](GOOGLE_GEMINI_SETUP_GUIDE.md)
- **Check Console Logs**: Open Xcode Console (⌘ + Shift + C) for detailed error messages

## Future Enhancements

- [ ] Support for multiple target languages
- [ ] Translation history and favorites
- [ ] Offline caching of translations
- [ ] PDF and document support
- [ ] Voice reading of translations
- [ ] Custom word limit per translation
- [ ] Share translated content

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available for personal and educational use.

## Resources

- [Google Gemini API Documentation](https://ai.google.dev/docs)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

## Support

For issues related to:
- **Google Gemini API**: See [GOOGLE_GEMINI_SETUP_GUIDE.md](GOOGLE_GEMINI_SETUP_GUIDE.md)
- **iOS Development**: Check Apple Developer Forums
- **This Project**: Open an issue in the repository

---

**Version**: 1.0
**Last Updated**: November 12, 2025
**Minimum iOS**: 18.6
