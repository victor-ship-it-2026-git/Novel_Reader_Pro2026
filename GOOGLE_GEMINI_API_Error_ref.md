Common Error Codes and Their Meanings:

400

code: 400 (status: "INVALID_ARGUMENT" or "BAD_REQUEST")
Meaning: You sent a request that the server couldn't understand or process because it was malformed, incomplete, or contained invalid parameters.
Examples:
Sending an empty prompt.
A prompt exceeding the model's token limit.
Incorrectly formatted JSON in the request body.
Specifying a non-existent temperature or topP value (e.g., negative).
Action: Review your request body, parameters, and ensure they conform to the API's specifications for the method you're calling.


401

code: 401 (status: "UNAUTHENTICATED")
Meaning: Your request lacks valid authentication credentials (e.g., a missing or invalid API key). The server doesn't know who you are.
Examples:
No apiKey configured.
An expired or revoked apiKey.
A typo in your apiKey.
Action: Double-check your API key configuration. Ensure it's correct, active, and included in your request.

403

code: 403 (status: "PERMISSION_DENIED" or "FORBIDDEN")
Meaning: You are authenticated, but you don't have the necessary permissions to perform the requested action. This is distinct from 401, where you're not authenticated at all.
Examples:
Your API key might not be enabled for the Generative AI API in your Google Cloud project.
The project associated with your API key might have hit a usage limit or budget cap.
Attempting to access a model that your account doesn't have explicit access to (e.g., a private model).
Action: Check your Google Cloud project settings, API enablement, billing status, and API key restrictions.

404

code: 404 (status: "NOT_FOUND")
Meaning: The requested resource was not found. This is the error you encountered.
Examples:
Incorrect model name: Like models/gemini-1.5-flash-latest when it should be models/gemini-1.5-flash.
Trying to call an endpoint or model that does not exist.
The model might not be available in the specific region you are targeting (though this is less common for global models).
Action: Verify the model name (GenerativeModel(name: "...")) and ensure it's correct and currently available. Use listModels() to confirm.

429

code: 429 (status: "RESOURCE_EXHAUSTED" or "TOO_MANY_REQUESTS")
Meaning: You have sent too many requests in a given amount of time and have exceeded your rate limits.
Examples:
Making API calls too rapidly.
Hitting a daily or per-minute quota limit.
Action: Implement exponential backoff and retry logic in your application. Check your project's quotas in the Google Cloud Console.

500

code: 500 (status: "INTERNAL_SERVER_ERROR")
Meaning: An unexpected error occurred on Google's servers. This is a problem on their end, not yours.
Examples:
Temporary server outage.
Bug in the API itself.
Action: These are usually transient. Implement retry logic. If it persists, check the Google Cloud status page or contact support.

503

code: 503 (status: "UNAVAILABLE")
Meaning: The service is temporarily unavailable, often due to maintenance or overload.
Examples:
Planned service maintenance.
Temporary high traffic leading to server overload.
Action: Similar to 500, this is usually transient. Implement retry logic with exponential backoff.
