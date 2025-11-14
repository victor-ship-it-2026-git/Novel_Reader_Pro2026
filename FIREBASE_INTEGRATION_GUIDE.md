# Firebase Integration Guide

## Overview

The Novel Reader Pro app is now integrated with Firebase Realtime Database to store and manage novel chapter URLs. This allows you to:

- Store URLs in Firebase database
- Automatically extract content from those URLs
- Translate content using Google Gemini AI
- Track processing status for each URL

## Features

### 1. Firebase Database Structure

The app uses Firebase Realtime Database with the following structure:

```
novelURLs/
  ├── {url-id-1}/
  │   ├── id: "uuid-string"
  │   ├── url: "https://example.com/chapter-1"
  │   ├── title: "Novel Title - Chapter 1"
  │   ├── description: "Optional description"
  │   ├── language: "en" (source language)
  │   ├── targetLanguage: "my" (target translation language)
  │   ├── addedDate: 1699999999 (timestamp)
  │   ├── lastProcessedDate: 1699999999 (timestamp)
  │   └── status: "pending|processing|completed|failed"
  ├── {url-id-2}/
  │   └── ...
```

### 2. URL Status Tracking

Each URL has a status that tracks its processing state:

- **pending**: URL added but not yet processed
- **processing**: Currently extracting content
- **completed**: Successfully extracted and translated
- **failed**: Error occurred during processing

### 3. App Interface

The app now has a **tab-based interface** with two main sections:

#### Tab 1: Manual Input
- Enter URLs manually
- Paste text directly for processing
- Original functionality from previous version

#### Tab 2: Firebase URLs
- View all URLs stored in Firebase
- Add new URLs to the database
- Process URLs (extract & translate)
- Delete URLs
- Real-time synchronization with Firebase

## How to Use

### Adding URLs to Firebase

**Option 1: Using the App Interface**

1. Open the app
2. Switch to the **Firebase URLs** tab
3. Tap the **"+"** button in the top right
4. Fill in the URL details:
   - **URL**: The chapter URL (required)
   - **Title**: Optional title for identification
   - **Description**: Optional description
   - **Source Language**: Default is English (en)
   - **Target Language**: Default is Burmese (my)
5. Tap **"Add"**

**Option 2: Using Firebase Console**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `novelbooks-ce211`
3. Navigate to **Realtime Database**
4. Create a new entry under `novelURLs/`:

```json
{
  "novelURLs": {
    "unique-id-here": {
      "id": "unique-id-here",
      "url": "https://novelbin.com/b/example-novel/chapter-1",
      "title": "Example Novel - Chapter 1",
      "description": "First chapter of the novel",
      "language": "en",
      "targetLanguage": "my",
      "addedDate": 1699999999,
      "status": "pending"
    }
  }
}
```

### Processing URLs

1. Open the **Firebase URLs** tab
2. Tap on any URL from the list
3. Tap **"Extract Content"** to fetch and parse the chapter
4. Review the extracted content
5. Tap **"Translate to [language]"** to translate
6. The status will automatically update to "completed"

### Managing URLs

**Delete a URL:**
- Swipe left on any URL in the list
- Tap the **"Delete"** button

**View URL Details:**
- Tap on any URL to see full details
- View status, languages, and timestamps

## Database Operations

The `FirebaseService` class provides the following operations:

### Read Operations
```swift
// Fetch all URLs
try await firebaseService.fetchURLs()

// Get pending URLs only
let pending = firebaseService.getPendingURLs()

// Get specific URL
let url = firebaseService.getURL(by: "url-id")
```

### Write Operations
```swift
// Add a new URL
let novelURL = NovelURL(url: "https://example.com/chapter-1")
try await firebaseService.addURL(novelURL)

// Update URL status
try await firebaseService.updateURLStatus(id: "url-id", status: .completed)

// Update entire URL
try await firebaseService.updateURL(novelURL)

// Add multiple URLs
try await firebaseService.addURLs([url1, url2, url3])
```

### Delete Operations
```swift
// Delete a single URL
try await firebaseService.deleteURL(id: "url-id")

// Delete all URLs
try await firebaseService.deleteAllURLs()
```

## Real-time Synchronization

The app uses Firebase's real-time listener to automatically update the UI when:
- New URLs are added to the database
- URLs are modified
- URLs are deleted
- Status changes occur

This means multiple devices can stay in sync automatically.

## Translation Workflow

1. **URL Storage**: URLs are stored in Firebase with metadata
2. **Content Extraction**: The app fetches the URL and extracts chapter content using advanced HTML parsing
3. **Translation**: Extracted content is translated using Google Gemini AI
4. **Status Updates**: Processing status is automatically updated in Firebase

## Supported Novel Websites

The content extraction system supports various novel websites including:
- novelbin.com
- wuxiaworld.com
- And other sites using standard HTML structures

The parser uses multiple CSS selectors to find content across different website layouts.

## Translation Settings

### Supported Languages

**Source Languages:**
- English (en)
- Chinese (zh)
- Japanese (ja)
- Korean (ko)

**Target Languages:**
- Burmese (my) - Default
- English (en)
- Thai (th)

### Google Gemini Configuration

The app uses Google Gemini AI with the following settings:
- **Model**: gemini-2.5-flash
- **API Key**: Configured in `Config.swift`
- **Max Word Count**: 5000 words per translation
- **Temperature**: 0.3 (for consistent translations)

## Firebase Security Rules

Make sure your Firebase Realtime Database has appropriate security rules:

```json
{
  "rules": {
    "novelURLs": {
      ".read": "auth != null || true",
      ".write": "auth != null || true",
      "$urlId": {
        ".validate": "newData.hasChildren(['id', 'url', 'status', 'addedDate'])"
      }
    }
  }
}
```

**Note**: The above rules allow public read/write for development. For production, implement proper authentication.

## Error Handling

The app handles various errors:
- **Network Errors**: Failed to fetch URL content
- **Parsing Errors**: Unable to extract chapter content
- **Translation Errors**: Gemini API failures
- **Firebase Errors**: Database operation failures

All errors are displayed to the user with descriptive messages.

## Limitations

- **Free Tier Limits** (Google Gemini):
  - 15 requests/minute
  - 1,500 requests/day
  - 1 million tokens/minute

- **Content Limit**: 5000 words per chapter (configurable in `Config.swift`)

- **Firebase Realtime Database**:
  - 100 simultaneous connections (Spark plan)
  - 1 GB stored data (Spark plan)
  - 10 GB/month downloaded (Spark plan)

## Troubleshooting

### URLs not appearing in the app
1. Check Firebase Console to verify URLs are stored correctly
2. Ensure Firebase is initialized (check console logs)
3. Try pulling down to refresh the list

### Extraction fails
1. Verify the URL is accessible
2. Check if the website structure is supported
3. Try using "Direct Text" mode in the Manual Input tab

### Translation fails
1. Check your Gemini API key in `Config.swift`
2. Verify you haven't exceeded rate limits
3. Check internet connection

### Status not updating
1. Check Firebase security rules
2. Verify internet connection
3. Check console logs for errors

## Code Files

### Core Firebase Integration
- `FirebaseService.swift` - Database operations service
- `NovelURL.swift` - Data model for URLs
- `FirebaseURLManagerView.swift` - UI for Firebase URL management
- `MainTabView.swift` - Tab interface combining manual and Firebase modes

### Existing Services (Reused)
- `WebContentService.swift` - Web content fetching
- `HTMLParser.swift` - Advanced HTML parsing
- `TextExtractor.swift` - Text extraction
- `GeminiTranslationService.swift` - AI translation
- `ChapterContent.swift` - Chapter data model

## Next Steps

1. **Add Authentication**: Implement Firebase Authentication for secure access
2. **Batch Processing**: Add ability to process multiple URLs automatically
3. **Caching**: Store extracted and translated content locally
4. **Push Notifications**: Notify when processing is complete
5. **Sharing**: Share extracted/translated content with others

## Support

For issues or questions:
1. Check the Firebase Console for database errors
2. Review the Xcode console for app logs
3. Refer to the existing documentation:
   - `README.md`
   - `GOOGLE_GEMINI_SETUP_GUIDE.md`
   - `XCODE_CONFIGURATION_GUIDE.md`
