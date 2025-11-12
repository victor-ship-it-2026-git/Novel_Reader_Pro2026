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

### Step 2: Test Translation

1. In the app, you'll see a text field for entering a URL
2. Click the clipboard icon to use the sample URL, or enter your own
3. Click the "Fetch & Translate" button
4. Wait for the translation to complete

### Step 3: Verify Results

If successful, you should see:
- **Original Text (English)**: The extracted text from the URL
- **Translated Text (Burmese)**: The Burmese translation

If you encounter errors, see the [Troubleshooting](#troubleshooting) section below.

---

## API Usage Limits and Pricing

### Free Tier Limits (as of 2025)

Google Gemini API offers a generous free tier:

- **Rate Limits**:
  - 60 requests per minute (RPM)
  - 1,500 requests per day (RPD)
  - 1 million tokens per minute (TPM)

- **Model**: `gemini-pro`
  - Optimized for text generation and understanding
  - Supports multiple languages including Burmese

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

### Error: "Invalid API key"

**Problem**: The API key is not valid or not configured correctly.

**Solutions**:
1. Double-check that you copied the entire API key
2. Ensure there are no extra spaces or characters
3. Verify the API key is active in Google Cloud Console
4. Make sure you're using a Gemini API key, not another Google API key

### Error: "API key not valid. Please pass a valid API key."

**Problem**: The API key format is incorrect or the key is disabled.

**Solutions**:
1. Regenerate your API key in Google AI Studio
2. Check if your API key has been restricted and needs additional configuration
3. Ensure "Generative Language API" is enabled in your Google Cloud project

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
