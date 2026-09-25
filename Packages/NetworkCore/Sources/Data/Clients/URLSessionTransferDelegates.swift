import Foundation

final class DownloadTransferDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    private let request: DownloadRequest
    private let progressHandler: @Sendable (DownloadProgress) -> Void
    private let lock = NSLock()
    private var continuation: CheckedContinuation<DownloadResponse, Error>?
    private var completed = false

    init(
        request: DownloadRequest,
        progressHandler: @escaping @Sendable (DownloadProgress) -> Void
    ) {
        self.request = request
        self.progressHandler = progressHandler
    }

    func start(with session: URLSession, request urlRequest: URLRequest) async throws -> DownloadResponse {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                lock.withLock { self.continuation = continuation }
                session.downloadTask(with: urlRequest).resume()
            }
        } onCancel: {
            session.invalidateAndCancel()
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        progressHandler(
            DownloadProgress(
                request: request,
                bytesWritten: bytesWritten,
                totalBytesWritten: totalBytesWritten,
                totalBytesExpectedToWrite: totalBytesExpectedToWrite
            )
        )
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            try FileManager.default.createDirectory(
                at: request.destinationURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if FileManager.default.fileExists(atPath: request.destinationURL.path) {
                try FileManager.default.removeItem(at: request.destinationURL)
            }
            try FileManager.default.moveItem(at: location, to: request.destinationURL)
            finish(
                .success(
                    DownloadResponse(
                        request: request,
                        localURL: request.destinationURL,
                        response: downloadTask.response,
                        progress: 1
                    )
                )
            )
        } catch {
            finish(.failure(error))
        }
        session.finishTasksAndInvalidate()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error { finish(.failure(error)) }
    }

    private func finish(_ result: Result<DownloadResponse, Error>) {
        let continuation: CheckedContinuation<DownloadResponse, Error>? = lock.withLock {
            guard !completed else { return nil }
            completed = true
            defer { self.continuation = nil }
            return self.continuation
        }
        continuation?.resume(with: result)
    }
}

final class UploadTransferDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let request: UploadRequest
    private let progressHandler: @Sendable (UploadProgress) -> Void
    private let lock = NSLock()
    private var responseData = Data()
    private var continuation: CheckedContinuation<(Data, URLResponse), Error>?
    private var completed = false

    init(
        request: UploadRequest,
        progressHandler: @escaping @Sendable (UploadProgress) -> Void
    ) {
        self.request = request
        self.progressHandler = progressHandler
    }

    func start(
        with session: URLSession,
        urlRequest: URLRequest,
        fileURL: URL
    ) async throws -> (Data, URLResponse) {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                lock.withLock { self.continuation = continuation }
                session.uploadTask(with: urlRequest, fromFile: fileURL).resume()
            }
        } onCancel: {
            session.invalidateAndCancel()
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        progressHandler(
            UploadProgress(
                request: request,
                bytesSent: bytesSent,
                totalBytesSent: totalBytesSent,
                totalBytesExpectedToSend: totalBytesExpectedToSend
            )
        )
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        lock.withLock { responseData.append(data) }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error {
            finish(.failure(error))
        } else if let response = task.response {
            let data = lock.withLock { responseData }
            finish(.success((data, response)))
        } else {
            finish(.failure(NetworkError.invalidResponse))
        }
        session.finishTasksAndInvalidate()
    }

    private func finish(_ result: Result<(Data, URLResponse), Error>) {
        let continuation: CheckedContinuation<(Data, URLResponse), Error>? = lock.withLock {
            guard !completed else { return nil }
            completed = true
            defer { self.continuation = nil }
            return self.continuation
        }
        continuation?.resume(with: result)
    }
}
