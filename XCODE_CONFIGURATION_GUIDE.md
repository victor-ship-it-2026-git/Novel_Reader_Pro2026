# Xcode Configuration Guide for Novel Reader Pro

This guide walks you through the necessary Xcode configurations to ensure your app works correctly with network requests.

## Table of Contents
1. [Network Permissions Configuration](#network-permissions-configuration)
2. [Troubleshooting Network Issues](#troubleshooting-network-issues)
3. [Testing the App](#testing-the-app)
4. [Common Error Messages](#common-error-messages)

---

## Network Permissions Configuration

### Step 1: Enable Outgoing Network Connections

iOS 18 requires explicit permission for apps to make network connections. Follow these steps:

1. **Open Your Project in Xcode**
   - Open `Novel Book Reader.xcodeproj` in Xcode

2. **Select Your Target**
   - In the Project Navigator (left sidebar), click on the project name at the top
   - In the main panel, select the "Novel Book Reader" target under TARGETS

3. **Add Network Permissions to Info**
   - Click on the "Info" tab
   - Look for "Custom iOS Target Properties"

4. **Add App Transport Security Settings**

   Click the **"+"** button next to any existing property and add the following:

   **Key**: `App Transport Security Settings` (Type: Dictionary)

   Then click the disclosure triangle next to "App Transport Security Settings" and add:

   **Sub-key**: `Allow Arbitrary Loads` (Type: Boolean) = **YES**

   ⚠️ **Note**: For production apps, you should configure specific domain exceptions instead of allowing arbitrary loads. See the security section below.

### Step 2: Add Required Capabilities

Since you're using network APIs:

1. Go to **Signing & Capabilities** tab
2. Check if "Outgoing Connections (Client)" is enabled
3. If not present, click **"+ Capability"** and add:
   - **Outgoing Connections (Client)**: For making HTTP/HTTPS requests

### Alternative: Manual Info.plist Configuration

If you prefer to edit the Info.plist file directly:

1. **Find or Create Info.plist**
   - Right-click on "Novel Book Reader" folder in Project Navigator
   - Select "New File..."
   - Choose "Property List" and name it "Info.plist" if it doesn't exist

2. **Add the Following XML**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
```

---

## Security Best Practices for Production

### Option 1: Domain-Specific Exceptions (Recommended)

Instead of allowing all connections, specify only the domains you need:

**In Xcode Info tab, configure**:
```
App Transport Security Settings (Dictionary)
  └── Exception Domains (Dictionary)
      ├── generativelanguage.googleapis.com (Dictionary)
      │   └── NSExceptionAllowsInsecureHTTPLoads = NO
      │   └── NSIncludesSubdomains = YES
      │   └── NSExceptionRequiresForwardSecrecy = YES
      └── [your-target-domain.com] (Dictionary)
          └── NSExceptionAllowsInsecureHTTPLoads = NO
```

### Option 2: Using Privacy Manifest

For iOS 18+, consider adding a Privacy Manifest:

1. **Add Privacy Manifest File**
   - Right-click on your project folder
   - Select "New File..."
   - Search for "App Privacy"
   - Select "App Privacy File"
   - Name it `PrivacyInfo.xcprivacy`

2. **Configure Network Usage**
   - Add "NSPrivacyAccessedAPICategoryNetworkVolume"
   - Justify why your app needs network access

---

## Troubleshooting Network Issues

### Issue 1: "Invalid Response from Server"

**Possible Causes:**
1. Network permissions not configured
2. API key not set or invalid
3. Website blocking automated requests
4. No internet connection

**Solutions:**

1. **Check Network Permissions**
   - Verify App Transport Security settings (see above)
   - Ensure "Outgoing Connections (Client)" capability is enabled

2. **Verify API Key**
   - Open `Config.swift`
   - Ensure `geminiAPIKey` is set to your actual API key
   - Verify the key starts with "AIzaSy"

3. **Test Different URLs**
   - Try the sample Wikipedia URL first
   - Some websites block automated access
   - Try: `https://en.wikipedia.org/wiki/Apple`

4. **Check Internet Connection**
   - Ensure your Mac/simulator has internet access
   - Try accessing a website in Safari

### Issue 2: "The resource could not be loaded"

**Solution:**
- This usually means App Transport Security is blocking the request
- Follow the Network Permissions Configuration steps above

### Issue 3: "Failed to decode translation response"

**Solution:**
- The API response format may have changed
- Check your Gemini API key is valid
- Ensure you're using the correct API endpoint

### Issue 4: HTTP Status Code 403 or 401

**Solution:**
- 403: API key is invalid or restricted
- 401: API key is missing or not properly configured
- Double-check your API key in `Config.swift`
- Verify the API key has Gemini API permissions

---

## Testing the App

### Quick Test Checklist

1. ✅ **Build the Project**
   ```
   Press ⌘ + B to build
   Check for any compile errors
   ```

2. ✅ **Run on Simulator**
   ```
   Select iPhone 15 Pro simulator (or newer)
   Press ⌘ + R to run
   ```

3. ✅ **Test with Sample URL**
   ```
   Click the clipboard icon to load sample URL
   Click "Fetch & Translate"
   Wait for the translation to appear
   ```

4. ✅ **Verify Results**
   ```
   Check that Original Text appears
   Check that Translated Text (Burmese) appears
   Verify word count is displayed
   ```

### Debugging Network Requests

If you're still experiencing issues, add debug logging:

1. **Open the Console in Xcode**
   - Run the app
   - Open View → Debug Area → Activate Console (⌘ + Shift + C)

2. **Watch for Error Messages**
   - Network errors will appear in the console
   - Look for URLSession errors
   - Check HTTP status codes

---

## Common Error Messages

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Invalid API key" | API key not configured | Add your Gemini API key to Config.swift |
| "Invalid response from server (Status code: 403)" | Website blocking requests or API restrictions | Try different URL or check API key permissions |
| "Network error: The resource could not be loaded" | App Transport Security blocking | Configure ATS settings (see above) |
| "No text content could be extracted" | Page has no text or requires JavaScript | Try a different, simpler webpage |
| "API error: HTTP Status Code: 400" | Malformed API request | Check Gemini API endpoint in Config.swift |
| "API error: HTTP Status Code: 429" | Rate limit exceeded | Wait a few minutes and try again |

---

## Testing on Real Device

### Step 1: Configure Device

1. Connect your iPhone via USB
2. Select your device from the device menu in Xcode
3. You may need to trust your Mac on the device

### Step 2: Code Signing

1. Go to **Signing & Capabilities**
2. Select your Apple ID team
3. Xcode will automatically manage signing

### Step 3: Run on Device

1. Press ⌘ + R
2. On your iPhone, you may need to:
   - Trust the developer certificate
   - Go to Settings → General → Device Management
   - Trust your developer certificate

---

## Performance Optimization

### Reducing Network Usage

1. **Adjust Word Limit**
   ```swift
   // In Config.swift
   static let maxWordCount = 200  // Reduce from 400 to save tokens
   ```

2. **Cache Translations** (Future Enhancement)
   - Store previous translations
   - Avoid re-translating same content

### Improving Response Time

1. **Use Faster Model** (if available)
   ```swift
   // In Config.swift, update endpoint to use gemini-pro-flash if needed
   ```

2. **Optimize Text Extraction**
   - The TextExtractor already removes scripts/styles
   - Further optimization may require custom HTML parsing

---

## Additional Resources

- **Apple Documentation**: [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- **App Transport Security**: [Apple ATS Guide](https://developer.apple.com/documentation/security/preventing_insecure_network_connections)
- **Network Debugging**: [Apple Network Debugging Guide](https://developer.apple.com/documentation/network/debugging_network_connectivity)
- **Xcode Console**: [Xcode Debugging](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)

---

## Need More Help?

If you're still experiencing issues:

1. **Check the Main README**: See [README.md](README.md)
2. **Review Gemini API Setup**: See [GOOGLE_GEMINI_SETUP_GUIDE.md](GOOGLE_GEMINI_SETUP_GUIDE.md)
3. **Verify Network Connection**: Test in Safari first
4. **Try Different URLs**: Some sites block automated access

---

**Last Updated**: November 12, 2025
**iOS Version**: 18.6+
**Xcode Version**: 15.0+
