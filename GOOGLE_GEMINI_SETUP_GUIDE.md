# Google Gemini API Setup Guide

This guide will walk you through the process of setting up Google Gemini API for your iOS app.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Creating a Google Cloud Account](#creating-a-google-cloud-account)
3. [Getting Your Gemini API Key](#getting-your-gemini-api-key)
4. [Configuring the API Key in Your App](#configuring-the-api-key-in-your-app)
5. [Testing Your API Connection](#testing-your-api-connection)
6. [API Usage Limits and Pricing](#api-usage-limits-and-pricing)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have:
- A Google account (Gmail, Google Workspace, etc.)
- Internet access
- Xcode installed on your Mac
- This iOS project opened in Xcode

---

## Creating a Google Cloud Account

1. **Visit Google Cloud Console**
   - Go to [https://console.cloud.google.com](https://console.cloud.google.com)
   - Sign in with your Google account

2. **Accept Terms of Service**
   - If this is your first time, you'll be prompted to accept Google Cloud's Terms of Service
   - Read and accept the terms

3. **Set Up Billing (Optional for Free Tier)**
   - Google Gemini API offers a free tier with generous limits
   - You can start without adding a payment method for the free tier
   - Note: Some features may require billing to be enabled

---

## Getting Your Gemini API Key

### Step 1: Access Google AI Studio

1. Go to **Google AI Studio** (formerly MakerSuite):
   - URL: [https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)
   - Or visit [https://aistudio.google.com](https://aistudio.google.com) and click on "Get API key"

2. Sign in with your Google account if not already signed in

### Step 2: Create a New API Key

1. **Click on "Create API Key" or "Get API Key"**
   - You'll see a button labeled "Create API key" or "Get API key" at the top

2. **Select or Create a Google Cloud Project**
   - Option 1: Create a new project
     - Click "Create API key in new project"
     - A new project will be automatically created

   - Option 2: Use an existing project
     - Click "Create API key in existing project"
     - Select your project from the dropdown list

3. **Copy Your API Key**
   - Once created, your API key will be displayed
   - Click the "Copy" icon to copy it to your clipboard
   - **IMPORTANT**: Store this key securely. Don't share it publicly!

   Example API key format:
   ```
   AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

### Step 3: (Optional) Restrict Your API Key

For production apps, it's highly recommended to restrict your API key:

1. Go to [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)

2. Find your API key in the list and click on it

3. **Application Restrictions**
   - Choose "iOS apps"
   - Add your app's Bundle ID (e.g., `com.yourcompany.novelbookreader`)

4. **API Restrictions**
   - Select "Restrict key"
   - Check "Generative Language API"

5. Click "Save"

---

## Configuring the API Key in Your App

### Step 1: Open the Config File

1. In Xcode, navigate to your project
2. Open the file: `Novel Book Reader/Config.swift`

### Step 2: Add Your API Key

1. Find this line:
   ```swift
   static let geminiAPIKey = "YOUR_GEMINI_API_KEY_HERE"
   ```

2. Replace `"YOUR_GEMINI_API_KEY_HERE"` with your actual API key:
   ```swift
   static let geminiAPIKey = "AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   ```

3. Save the file (⌘ + S)

### Step 3: Security Best Practices

⚠️ **IMPORTANT SECURITY NOTES:**

1. **Never commit API keys to version control**
   - The `Config.swift` file should be added to `.gitignore`
   - Consider using environment variables or a secure configuration system

2. **For Production Apps:**
   - Use a backend server to handle API calls
   - Implement API key restrictions in Google Cloud Console
   - Consider using Firebase or a similar service for secure key management

3. **Add Config.swift to .gitignore**
   ```bash
   # Open Terminal in your project directory
   echo "Novel Book Reader/Config.swift" >> .gitignore
   ```

---

## Testing Your API Connection

### Step 1: Build and Run the App

1. In Xcode, select a simulator or connect your iOS device
2. Click the "Run" button (▶️) or press ⌘ + R
3. Wait for the app to build and launch

### Step 2: Use the Debug Tool (Recommended) 🔧

**Before trying to translate, use the built-in debug tool to verify your API setup:**

1. **Open the Debug Tool**
   - Tap the wrench icon (🔧) in the top-right corner of the app
   - This will open the API Debug Tool

2. **Verify Your API Key**
   - The tool will display the first 10 characters of your configured API key
   - Make sure it matches your actual API key

3. **Test API Connection**
   - Tap the "Test API Connection" button
   - The tool will perform comprehensive diagnostics

4. **Review Debug Results**
   - **Available Models Section**: Lists all Gemini models accessible with your API key
     - If this section appears, your API is working correctly! ✅
     - Note which models are listed (e.g., gemini-1.5-flash, gemini-1.5-pro)

   - **Debug Log Section**: Shows detailed test results
     - Green checkmarks (✅) mean the test passed
     - Red X marks (❌) indicate issues that need fixing

5. **Update Config (if needed)**
   - If the available models list shows different model names than what's in `Config.swift`, update your config:
   ```swift
   static let geminiModel = "model-name-from-debug-tool"
   ```

6. **Copy Debug Log (for troubleshooting)**
   - Tap "Copy" button to copy the debug log
   - Useful for sharing when seeking help

**What the Debug Tool Tests:**
- ✓ Lists all available Gemini models via API
- ✓ Tests common model names (gemini-pro, gemini-1.5-pro, gemini-1.5-flash, etc.)
- ✓ Shows HTTP status codes and API responses
- ✓ Identifies specific API errors (404, 403, 401)
- ✓ Verifies API key validity and permissions

### Step 3: Test Translation

Once the debug tool confirms your API is working:

1. Go back to the main screen (swipe down or tap outside the debug view)
2. In the app, you'll see a text field for entering a URL
3. Click the clipboard icon to use the sample URL, or enter your own
4. Click the "Fetch & Translate" button
5. Wait for the translation to complete

### Step 4: Verify Results

If successful, you should see:
- **Original Text (English)**: The extracted text from the URL
- **Translated Text (Burmese)**: The Burmese translation

If you encounter errors, the debug tool will help identify the specific issue. See the [Troubleshooting](#troubleshooting) section below.

---

## API Usage Limits and Pricing

### Free Tier Limits (as of 2025)

Google Gemini API offers a generous free tier:

- **Rate Limits**:
  - 15 requests per minute (RPM) for free tier
  - 1,500 requests per day (RPD)
  - 1 million tokens per minute (TPM)

- **Model**: `gemini-1.5-flash` (default)
  - Fast and efficient for text translation
  - Optimized for text generation and understanding
  - Supports multiple languages including Burmese
  - Alternative: `gemini-1.5-pro` (more capable but slower)

### Checking Your Usage

1. Visit [Google Cloud Console - API Dashboard](https://console.cloud.google.com/apis/dashboard)
2. Select your project
3. Click on "Generative Language API"
4. View your usage metrics and quotas

### Pricing for Paid Tier

- The free tier is sufficient for development and moderate usage
- For high-volume production apps, check current pricing at:
  - [Google AI Pricing](https://ai.google.dev/pricing)

---

## Troubleshooting

### 🔧 Always Start with the Debug Tool!

Before troubleshooting any issue, **run the debug tool first**:
1. Tap the wrench icon (🔧) in the app
2. Tap "Test API Connection"
3. Review the debug log to identify the exact issue

The debug tool will show you:
- Which models are available for your API key
- Specific error codes (404, 403, 401)
- API response details
- Whether your API key is valid

### Error: "models/gemini-pro is not found" or "404 Not Found"

**Problem**: The model name in your config doesn't exist or isn't available.

**Solutions**:
1. **Use the Debug Tool** (🔧) to see which models are available
   - The "Available Models" section will list all models you can use
   - Copy one of the working model names

2. **Update your Config.swift** with a working model name:
   ```swift
   static let geminiModel = "gemini-1.5-flash-latest"  // or another model from debug tool
   ```

3. **If no models are listed** in the debug tool:
   - Your Generative Language API may not be enabled
   - Go to [Google Cloud Console](https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com)
   - Select your project and click "Enable"

4. Clean and rebuild your project (⌘ + Shift + K, then ⌘ + B)

### Error: "Invalid API key"

**Problem**: The API key is not valid or not configured correctly.

**Solutions**:
1. **Use the Debug Tool** (🔧) - it will verify if your API key works
   - Look for error code 401 in the debug log (invalid API key)
   - Look for error code 403 (API key restrictions)

2. Double-check that you copied the entire API key
3. Ensure there are no extra spaces or characters
4. Verify the API key is active in Google Cloud Console
5. Make sure you're using a Gemini API key, not another Google API key

### Error: "API key not valid. Please pass a valid API key."

**Problem**: The API key format is incorrect or the key is disabled.

**Solutions**:
1. **Check the Debug Tool** (🔧) - it will show the exact error message
2. Regenerate your API key in Google AI Studio
3. Check if your API key has been restricted and needs additional configuration
4. Ensure "Generative Language API" is enabled in your Google Cloud project

### Error: "Network error" or "Connection failed"

**Problem**: The app cannot reach the Gemini API.

**Solutions**:
1. Check your internet connection
2. Verify the API endpoint URL in `Config.swift` is correct
3. Check if you're behind a firewall or proxy that might block API calls
4. Try running the app on a different network

### Error: "Invalid response from Gemini API"

**Problem**: The API returned an unexpected response.

**Solutions**:
1. Check your API quota hasn't been exceeded
2. Verify the input text is not too long
3. Check the Gemini API status page for any outages
4. Review the API response in the console for more details

### Error: "Failed to decode translation response"

**Problem**: The app couldn't parse the API response.

**Solutions**:
1. Ensure you're using the latest version of the app code
2. Check if the Gemini API response format has changed
3. Verify your internet connection is stable

### The translated text is empty or incorrect

**Problem**: Translation completed but results are not as expected.

**Solutions**:
1. Try with a different URL or text
2. Check if the source text has enough content (not just HTML)
3. Verify the word limit (currently 400 words) in `Config.swift`
4. Some web pages may have restricted access or anti-scraping measures

---

## Additional Resources

### Official Documentation

- **Google AI Studio**: [https://aistudio.google.com](https://aistudio.google.com)
- **Gemini API Documentation**: [https://ai.google.dev/docs](https://ai.google.dev/docs)
- **API Reference**: [https://ai.google.dev/api](https://ai.google.dev/api)
- **Google Cloud Console**: [https://console.cloud.google.com](https://console.cloud.google.com)

### Useful Links

- **Pricing**: [https://ai.google.dev/pricing](https://ai.google.dev/pricing)
- **Quotas and Limits**: [https://ai.google.dev/docs/quota](https://ai.google.dev/docs/quota)
- **Best Practices**: [https://ai.google.dev/docs/best_practices](https://ai.google.dev/docs/best_practices)
- **Community Forum**: [https://discuss.ai.google.dev](https://discuss.ai.google.dev)

---

## Support

If you continue to experience issues:

1. **Check Google AI Status**: Visit [https://status.cloud.google.com](https://status.cloud.google.com)
2. **Review Error Messages**: Check the Xcode console for detailed error messages
3. **Contact Support**: Use the Google Cloud support options for your account tier

---

## Next Steps

Once your API is set up and working:

1. **Customize the word limit**: Edit `Config.maxWordCount` in `Config.swift`
2. **Add more languages**: Modify the translation prompt in `GeminiTranslationService.swift`
3. **Improve text extraction**: Enhance `TextExtractor.swift` for better HTML parsing
4. **Add offline caching**: Store translations locally for offline access
5. **Implement history**: Save translation history for later reference

---

**Last Updated**: November 12, 2025
**Version**: 1.0
