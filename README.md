# Novel Reader Pro - English to Burmese Translator

An iOS app built with Swift and SwiftUI that fetches content from web URLs and translates it from English to Burmese using Google Gemini AI.

## Features

- 📱 **iOS 18.6+ Compatible**: Built with the latest Swift and iOS technologies
- 🌐 **Web Content Fetching**: Automatically fetches and extracts text from any web URL
- 🔤 **Smart Text Extraction**: Removes HTML tags and extracts clean, readable text
- 🌍 **AI-Powered Translation**: Uses Google Gemini AI for accurate English to Burmese translation
- ⚡ **Real-time Processing**: Async/await based for smooth, non-blocking UI
- 📊 **Word Count Limiting**: Configurable word limit (currently 400 words) to manage API usage
- 🎨 **Modern SwiftUI Interface**: Clean, intuitive user interface

## Project Structure

```
Novel Book Reader/
├── Novel_Book_ReaderApp.swift      # Main app entry point
├── ContentView.swift                # Main UI view with translation interface
├── Config.swift                     # Configuration file for API keys and settings
├── WebContentService.swift          # Service for fetching web content
├── TextExtractor.swift              # Utility for extracting text from HTML
└── GeminiTranslationService.swift   # Google Gemini AI translation service
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

### 2. Get Your Google Gemini API Key

Follow the detailed instructions in [GOOGLE_GEMINI_SETUP_GUIDE.md](GOOGLE_GEMINI_SETUP_GUIDE.md) to:
- Create a Google Cloud account
- Get your Gemini API key
- Configure API restrictions (optional but recommended)

### 3. Configure Your API Key

1. Open the project in Xcode
2. Navigate to `Novel Book Reader/Config.swift`
3. Replace `"YOUR_GEMINI_API_KEY_HERE"` with your actual API key:

```swift
static let geminiAPIKey = "AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 4. Build and Run

1. Select a simulator or connect your iOS device
2. Press ⌘ + R or click the Run button
3. The app will build and launch

## Usage

1. **Enter a URL**: Type or paste a web URL in the text field
   - Or click the clipboard icon to use the sample Wikipedia URL

2. **Fetch & Translate**: Tap the "Fetch & Translate" button
   - The app will fetch the web content
   - Extract the first 400 words of text
   - Translate from English to Burmese

3. **View Results**:
   - **Original Text**: Shows the extracted English text
   - **Translated Text**: Shows the Burmese translation

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
- **GeminiTranslationService**: Manages communication with Google Gemini AI API
- **TextExtractor**: Processes HTML and extracts plain text

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Async/Await**: For asynchronous network operations
- **Combine**: For reactive state management
- **URLSession**: For network requests
- **Codable**: For JSON encoding/decoding

## API Usage and Limits

### Free Tier Limits
- **60 requests per minute**
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

### Common Issues

1. **"Invalid API key" error**
   - Double-check your API key in `Config.swift`
   - Ensure there are no extra spaces or characters

2. **"Network error"**
   - Check your internet connection
   - Verify the URL is accessible

3. **Empty translation**
   - Try a different URL
   - Some websites may block automated content fetching

For more detailed troubleshooting, see [GOOGLE_GEMINI_SETUP_GUIDE.md](GOOGLE_GEMINI_SETUP_GUIDE.md).

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
