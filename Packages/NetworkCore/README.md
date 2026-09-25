# NetworkCore

NetworkCore provides networking without depending on UI or TCA. Domain contains requests, responses, protocols, and errors. Data contains URLSession clients, request building, and response handling. Cross-cutting behavior such as queues, caching, authentication, and logging lives in interceptor-oriented components.

## Capabilities

- Single requests with `send`
- Bounded concurrent requests with `sendMultiple`
- Sequential requests using an awaited loop
- Priority scheduling with `RequestQueue`
- Single and concurrent file downloads
- File upload and multipart upload
- In-memory response caching with `NetworkCache`
- Headers, query parameters, JSON bodies, timeout, retry, and URL cache policies
- Type erasure through `AnyNetworkClient`

## Single, concurrent, and sequential requests

```swift
let client = AnyNetworkClient.live
let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
let request = NetworkRequest(baseURL: baseURL, path: "/posts/1")
let response = try await client.send(request)

let requests = (1...4).map {
    NetworkRequest(baseURL: baseURL, path: "/posts/\($0)")
}
let concurrent = try await client.sendMultiple(requests, maxConcurrent: 2)

var sequential: [NetworkResponse] = []
for request in requests {
    sequential.append(try await client.send(request))
}
```

The live client's `sendMultiple` implementation preserves input order while limiting active tasks.

## Priority queue

```swift
let configuration = URLSessionNetworkClient.NetworkConfiguration(baseURL: baseURL)
let sessionClient = URLSessionNetworkClient(configuration: configuration)
let queue = RequestQueue(networkClient: sessionClient, maxConcurrentRequests: 2)

async let urgent = queue.enqueue(profileRequest, priority: .urgent)
async let normal = queue.enqueue(feedRequest, priority: .medium)
let responses = try await [urgent, normal]
```

Cancellation removes a waiting request or cancels its active task. `cancelAll()` resumes all waiting continuations with cancellation and clears the queue.

## Downloads and uploads

```swift
let destination = FileManager.default.temporaryDirectory.appending(path: "sample.jpg")
let download = DownloadRequest(url: imageURL, destinationURL: destination)
let downloaded = try await client.download(download)

let upload = UploadRequest(
    request: NetworkRequest(method: .post, baseURL: apiURL, path: "/upload"),
    fileURL: localFileURL,
    fileKey: "file",
    mimeType: "image/jpeg"
)
_ = try await client.upload(upload)
```

Use a throwing task group for multiple downloads. Use `URLSessionNetworkClient.uploadMultipart` when form fields and multipart body construction are required.

## Cache

```swift
let cache = NetworkCache(defaultExpiration: 300)
await cache.store(response, for: request, policy: .memoryOnly)
let cached = await cache.retrieve(for: request)
await cache.remove(for: request)
```

Map `NetworkError` to stable UI failures at the feature boundary. Never swallow cancellation, log credentials, or use HTTP for production endpoints.
