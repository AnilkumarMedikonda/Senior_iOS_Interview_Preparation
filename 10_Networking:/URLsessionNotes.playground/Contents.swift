
import Foundation


// MARK: - URLSession
/*
 URLSession is Apple's API for HTTP/HTTPS networking.

 It is used to:
 - Send API requests
 - Receive server responses
 - Upload data/files
 - Download files
 - Cancel requests
 - Handle caching
 - Perform background transfers
 - Handle advanced networking through delegates

 Basic flow:

 URL
   ↓
 URLRequest
   ↓
 URLSession
   ↓
 URLSessionTask
   ↓
 Server
   ↓
 Response
*/


// MARK: - URL
/*
 URL represents the address of a resource or API endpoint.

 Example:
 https://api.example.com/products

 Use URL when:
 - Defining an API endpoint
 - Creating a resource URL

 For query parameters, prefer:
 URLComponents + URLQueryItem
*/


// MARK: - URLRequest
/*
 URLRequest defines HOW one request should be sent.

 It can contain:
 - HTTP method
 - Headers
 - Request body
 - Timeout
 - Cache policy

 Example:

 var request = URLRequest(url: url)
 request.httpMethod = "GET"

 Mental model:

 URL
 → Where?

 URLRequest
 → How?
*/


// MARK: - HTTP Methods
/*
 HTTP methods describe what the client wants to do.

 GET
 → Retrieve data

 POST
 → Create/send data

 PUT
 → Replace a resource

 PATCH
 → Partially update a resource

 DELETE
 → Delete a resource
*/


// MARK: - HTTP Headers
/*
 Headers provide additional information about a request/response.

 Common headers:

 Accept
 → Response format the client accepts

 Content-Type
 → Format of the request body

 Authorization
 → Authentication credentials

 Example:

 request.setValue(
     "application/json",
     forHTTPHeaderField: "Accept"
 )
*/


// MARK: - Query Parameters
/*
 Query parameters are values added to the URL.

 Example:

 /products?page=2&limit=20

 Common uses:
 - Search
 - Pagination
 - Filtering
 - Sorting

 Prefer URLComponents and URLQueryItem.

 Example:

 var components = URLComponents(
     string: "https://api.example.com/products"
 )

 components?.queryItems = [
     URLQueryItem(name: "page", value: "2"),
     URLQueryItem(name: "limit", value: "20")
 ]
*/


// MARK: - URLSession Execution
/*
 URLSession performs network operations.

 Example:

 let session = URLSession.shared

 A custom session can be created using:
 URLSessionConfiguration

 Mental model:

 URLRequest
     ↓
 URLSession
     ↓
 Execute request
*/


// MARK: - URLSessionTask
/*
 URLSessionTask represents one network operation.

 Main task types:

 URLSessionDataTask
 → Normal API/data requests

 URLSessionUploadTask
 → Upload data/files

 URLSessionDownloadTask
 → Download files
*/


// MARK: - DataTask
/*
 URLSessionDataTask is commonly used for REST APIs.

 Use it for:
 - GET APIs
 - POST APIs
 - JSON responses
 - Product APIs
 - Search APIs
 - User APIs

 Response is normally received as Data.

 Server
   ↓
 Data
   ↓
 JSONDecoder
   ↓
 Swift Model
*/


// MARK: - UploadTask
/*
 URLSessionUploadTask is used to upload data or files.

 Use it for:
 - Image upload
 - Video upload
 - Document upload
 - Large file upload

 Production considerations:
 - Progress
 - Cancellation
 - Retry
 - Background transfer
*/


// MARK: - DownloadTask
/*
 URLSessionDownloadTask is used to download files.

 Use it for:
 - Large files
 - Videos
 - Documents
 - Offline content

 Important difference:

 DataTask:
 Server → Data in memory

 DownloadTask:
 Server → Temporary file

 DownloadTask is preferable for large file downloads
 because the entire response does not need to remain in memory.
*/


// MARK: - resume()
/*
 Creating a URLSessionTask does not normally start the request.

 Example:

 let task = session.dataTask(with: request)

 task.resume()

 resume()
 → Starts or resumes the task.
*/


// MARK: - cancel()
/*
 cancel() stops a URLSessionTask.

 Use it when:
 - User leaves the screen
 - Search text changes
 - Filter changes
 - Request is no longer required
 - User cancels a download

 Example:

 task.cancel()

 Senior point:

 Cancellation should be combined with protection against
 stale responses updating the UI.
*/


// MARK: - HTTPURLResponse
/*
 HTTPURLResponse provides HTTP-specific response information.

 Important properties:

 statusCode
 → HTTP status code

 allHeaderFields
 → Response headers

 url
 → Response URL

 Example:

 guard let response = response as? HTTPURLResponse else {
     return
 }
*/


// MARK: - HTTP Status Codes
/*
 2xx → Success

 200 OK
 201 Created
 204 No Content


 4xx → Client/request error

 400 Bad Request
 401 Unauthorized
 403 Forbidden
 404 Not Found


 5xx → Server error

 500 Internal Server Error
 502 Bad Gateway
 503 Service Unavailable


 Important:

 HTTP error != Transport error.

 A 404 means communication with the server succeeded,
 but the server returned an unsuccessful HTTP status.
*/


// MARK: - Transport / Network Error
/*
 Transport errors happen when the network operation itself fails.

 Examples:
 - No Internet
 - Timeout
 - DNS failure
 - Connection lost
 - Request cancelled

 Example:

 if let error {
     // Transport/network error
 }

 Mental model:

 Transport Error
 → Network communication failed

 HTTP Error
 → Server responded with 4xx/5xx
*/


// MARK: - URLSessionConfiguration
/*
 URLSessionConfiguration defines the behavior and policies
 of a URLSession.

 Mental model:

 Configuration
 → Rules

 URLSession
 → Worker

 URLSessionTask
 → Actual job
*/


// MARK: - .default
/*
 .default is the normal URLSession configuration.

 Use it for:
 - REST APIs
 - Products
 - Search
 - Login
 - Profile
 - Orders

 It provides standard URL loading behavior including
 caching, cookies and credentials according to configuration
 and HTTP rules.

 Remember:

 .default
 → Normal networking
*/


// MARK: - .ephemeral
/*
 .ephemeral is designed for temporary networking.

 It avoids normal persistent storage of session-related data.

 Use it when:
 - Temporary web sessions are required
 - Private browsing is needed
 - Persistent cookies/cache are not desired
 - Temporary authentication flows are needed

 Important:

 .ephemeral does NOT make the connection secure.

 HTTPS/TLS
 → Secure communication

 .ephemeral
 → Controls session persistence

 Remember:

 .ephemeral
 → Temporary networking
*/


// MARK: - .background
/*
 .background is designed for system-managed background transfers.

 Use it for:
 - Large file downloads
 - Large file uploads
 - Long-running transfers
 - Background file transfers

 Remember:

 .background
 → Long-running upload/download
*/


// MARK: - timeoutIntervalForRequest
/*
 How long to wait for the NEXT piece of data (idle timeout).
 The timer resets every time data arrives.

 Example:

 configuration.timeoutIntervalForRequest = 30

 Use it to prevent requests from waiting indefinitely.
*/


// MARK: - timeoutIntervalForResource
/*
 Maximum TOTAL time for the whole transfer (default: 7 days).

 Example:

 configuration.timeoutIntervalForResource = 60

 Mental model:

 timeoutIntervalForRequest
 → Idle time between data packets

 timeoutIntervalForResource
 → Total time for the whole transfer
*/


// MARK: - waitsForConnectivity
/*
 Allows the session to wait for connectivity in applicable cases.

 Example:

 configuration.waitsForConnectivity = true

 Mental model:

 No connectivity
      ↓
 Wait
      ↓
 Connectivity available
      ↓
 Request can continue
*/


// MARK: - Cache Policy
/*
 Cache policy controls how requests interact with cached responses.

 Common policies:

 .useProtocolCachePolicy
 → Follow normal HTTP caching rules

 .reloadIgnoringLocalCacheData
 → Ignore local cached data

 .returnCacheDataElseLoad
 → Use cache if available, otherwise load from network

 .returnCacheDataDontLoad
 → Use cache only

 Important:

 Persistent does NOT mean:
 "Always use cache."

 It means cached/session data can remain available
 for later use.

 Actual cache usage depends on:
 - Cache policy
 - HTTP caching headers
 - Cache validity
*/


// MARK: - URLCache
/*
 URLCache provides storage for HTTP cached responses.

 Conceptually:

 Request
    ↓
 URLCache
    ↓
 Cached response?
    ├── Yes → May use cache
    └── No  → Network

 Use it for:
 - HTTP response caching
 - Reducing network requests
 - Improving performance

 URLCache is NOT a replacement for:
 - Core Data
 - SQLite
 - Database
 - Application offline storage
*/


// MARK: - allowsCellularAccess
/*
 Controls whether the session can use cellular networking.

 Example:

 configuration.allowsCellularAccess = false

 Useful when you want to avoid cellular data,
 especially for large transfers.
*/


// MARK: - allowsExpensiveNetworkAccess
/*
 Controls whether the session can use networks
 that the system considers expensive.

 Example:

 configuration.allowsExpensiveNetworkAccess = false

 Useful for optional or large transfers where
 expensive network usage should be avoided.
*/


// MARK: - allowsConstrainedNetworkAccess
/*
 Controls whether the session can use constrained networks.

 Example:

 configuration.allowsConstrainedNetworkAccess = false

 Useful when optional network work should avoid
 constrained network conditions.
*/


// MARK: - URLSession Delegate
/*
 URLSession delegates provide advanced networking control.

 Use delegates for:
 - Authentication challenges
 - SSL Pinning
 - Background session events
 - Upload/download progress
 - Session lifecycle

 Example:

 final class NetworkDelegate:
     NSObject,
     URLSessionDelegate {
 }
*/


// MARK: - HTTPS vs Ephemeral
/*
 These concepts are different.

 HTTPS / TLS
 → Provides secure communication

 .ephemeral
 → Controls normal persistent session storage

 Therefore:

 .ephemeral != Security mechanism

 HTTPS/TLS = Security
 .ephemeral = Session persistence
*/


// MARK: - URLSession + Codable
/*
 URLSession normally gives us Data.

 Codable converts the Data into Swift models.

 Flow:

 Server
   ↓
 JSON
   ↓
 URLSession
   ↓
 Data
   ↓
 JSONDecoder
   ↓
 Swift Model

 This leads to:

 01_URLSession
      ↓
 02_Codable
*/


// MARK: - URLSession + API Client
/*
 In production applications, avoid putting URLSession
 code directly inside every ViewController.

 Recommended architecture:

 View
   ↓
 ViewModel
   ↓
 Repository
   ↓
 API Client
   ↓
 URLSession
   ↓
 Server

 API Client can centralize:
 - Request creation
 - Headers
 - Networking
 - Status validation
 - Decoding
 - Error handling
 - Authentication
 - Cancellation

 This is covered in:

 03_API_Client
*/


// MARK: - DataTask vs UploadTask vs DownloadTask
/*
 DataTask
 → Normal API/data requests

 UploadTask
 → Upload data/files

 DownloadTask
 → Download files


 Easy memory trick:

 DataTask
 → API response

 UploadTask
 → Send file/data

 DownloadTask
 → Receive file
*/


// MARK: - URLSession.shared vs Custom URLSession
/*
 URLSession.shared
 → Convenient preconfigured session
 → Good for simple networking


 Custom URLSession
 → More control over networking behavior

 Use custom sessions when you need:
 - Custom timeout
 - Cache configuration
 - Delegate
 - Background transfers
 - Connectivity policies
 - Special session behavior
*/


// MARK: - Senior Traps
/*
 1. Completion handler runs on a BACKGROUND thread
    → Update UI on the main thread.

 2. A session with a delegate keeps the delegate ALIVE
    → Call finishTasksAndInvalidate() when done, or it leaks.

 3. DownloadTask temp file is DELETED after the handler returns
    → Move / copy the file inside the handler.

 4. Background session NEEDS a delegate
    → Completion-handler tasks are not supported there.
*/


// MARK: - Complete Mental Model
/*
                         URL
                          ↓
                     URLRequest
                          ↓
                URLSessionConfiguration
                          ↓
                      URLSession
                          ↓
                   URLSessionTask
                   /      |       \
                  /       |        \
             DataTask UploadTask DownloadTask
                  \       |        /
                   \      |       /
                       Server
                         ↓
                 HTTPURLResponse
                         ↓
                    Status Code
                         ↓
                       Data
                         ↓
                    JSONDecoder
                         ↓
                    Swift Model
*/


// MARK: - Senior Interview Quick Revision
/*
 URL
 → Endpoint/resource address

 URLRequest
 → Defines one request

 URLSession
 → Performs networking

 URLSessionTask
 → Represents one operation

 DataTask
 → Normal API calls

 UploadTask
 → Upload data/files

 DownloadTask
 → Download files

 resume()
 → Starts/resumes task

 cancel()
 → Cancels task

 HTTPURLResponse
 → Status code + response headers

 2xx
 → Success

 4xx
 → Client/request error

 5xx
 → Server error

 Transport Error
 → Network-level failure

 Configuration
 → Session-level rules

 .default
 → Normal networking

 .ephemeral
 → Temporary networking

 .background
 → Background file transfers

 URLCache
 → HTTP response caching

 Delegate
 → Advanced networking

 HTTPS/TLS
 → Secure communication

 Codable
 → Data → Swift Model

 API Client
 → Centralized networking layer
*/


// MARK: - Senior Interview One-Liner
/*
 URLSession provides the networking infrastructure for HTTP/HTTPS
 communication, URLRequest defines an individual request,
 and URLSessionConfiguration controls the behavior of the session.
*/
