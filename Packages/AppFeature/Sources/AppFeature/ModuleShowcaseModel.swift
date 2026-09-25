import DomainCore
import Foundation
import NetworkCore
import Observation
import StorageCore

@MainActor
@Observable
final class ModuleShowcaseModel {
    enum DemoState: Equatable {
        case idle
        case running
        case success(String)
        case failure(String)
    }

    var networkState: DemoState = .idle
    var storageState: DemoState = .idle
    var downloadedImageURLs: [URL] = []

    private let client = AnyNetworkClient.live
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
    private let imageURLs = [
        URL(string: "https://picsum.photos/seed/modular-one/320/180")!,
        URL(string: "https://picsum.photos/seed/modular-two/320/180")!,
        URL(string: "https://picsum.photos/seed/modular-three/320/180")!
    ]

    func runSingleRequest() async {
        await runNetworkDemo {
            let response = try await self.client.send(self.postRequest(id: 1))
            let post = try response.decode(EntityPost.self)
            return "GET /posts/1 → \(response.statusCode)؛ \(post.title)"
        }
    }

    func runConcurrentRequests() async {
        await runNetworkDemo {
            let requests = (1...5).map(self.postRequest(id:))
            let responses = try await self.client.sendMultiple(requests, maxConcurrent: 3)
            return "۵ درخواست هم‌زمان با سقف ۳؛ \(responses.count) پاسخ موفق"
        }
    }

    func runSequentialRequests() async {
        await runNetworkDemo {
            var statusCodes: [Int] = []
            for id in 1...3 {
                let response = try await self.client.send(self.postRequest(id: id))
                statusCodes.append(response.statusCode)
            }
            return "۳ درخواست پشت‌سرهم؛ وضعیت‌ها: \(statusCodes.map(String.init).joined(separator: ", "))"
        }
    }

    func runPriorityQueue() async {
        await runNetworkDemo {
            let configuration = URLSessionNetworkClient.NetworkConfiguration(baseURL: self.baseURL)
            let queue = RequestQueue(
                networkClient: URLSessionNetworkClient(configuration: configuration),
                maxConcurrentRequests: 2
            )
            async let low = queue.enqueue(self.postRequest(id: 2), priority: .low)
            async let urgent = queue.enqueue(self.postRequest(id: 1), priority: .urgent)
            let responses = try await [low, urgent]
            return "صف اولویت‌دار؛ \(responses.count) پاسخ و active/pending برابر صفر"
        }
    }

    func runNetworkCache() async {
        await runNetworkDemo {
            let request = self.postRequest(id: 1)
            let response = try await self.client.send(request)
            let cache = NetworkCache(defaultExpiration: 60)
            await cache.store(response, for: request, policy: .memoryOnly)
            guard let entry = await cache.retrieve(for: request) else {
                throw ShowcaseError.verificationFailed("cache miss")
            }
            await cache.remove(for: request)
            return "NetworkCache؛ \(entry.data.count) بایت ذخیره، خوانده و حذف شد"
        }
    }

    func downloadSingleImage() async {
        await runNetworkDemo {
            let target = self.temporaryURL(name: "single-image.jpg")
            let response = try await self.client.download(
                DownloadRequest(url: self.imageURLs[0], destinationURL: target)
            )
            self.downloadedImageURLs = [response.localURL]
            return "دانلود تکی کامل شد؛ \(response.localURL.lastPathComponent)"
        }
    }

    func downloadMultipleImages() async {
        await runNetworkDemo {
            let client = self.client
            let imageURLs = self.imageURLs
            let files = try await withThrowingTaskGroup(of: (Int, URL).self) { group in
                for (index, url) in imageURLs.enumerated() {
                    let destination = self.temporaryURL(name: "image-\(index).jpg")
                    group.addTask {
                        let result = try await client.download(
                            DownloadRequest(url: url, destinationURL: destination)
                        )
                        return (index, result.localURL)
                    }
                }
                var values: [(Int, URL)] = []
                for try await value in group { values.append(value) }
                return values.sorted { $0.0 < $1.0 }.map(\.1)
            }
            self.downloadedImageURLs = files
            return "دانلود هم‌زمان \(files.count) تصویر کامل شد"
        }
    }

    func runUpload() async {
        await runNetworkDemo {
            let fileURL = self.temporaryURL(name: "upload-sample.txt")
            try await Task.detached {
                try FileManager.default.createDirectory(
                    at: fileURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try Data("Modular TCA upload sample".utf8).write(to: fileURL, options: .atomic)
            }.value
            let request = NetworkRequest(method: .post, baseURL: self.baseURL, path: "/posts")
            let response = try await self.client.upload(
                UploadRequest(request: request, fileURL: fileURL, mimeType: "text/plain")
            )
            return "آپلود فایل → HTTP \(response.statusCode)"
        }
    }

    func runPreferencesAndDiskCache() async {
        await runStorageDemo {
            let preferences = UserDefaultsStore()
            let preferenceKey = StorageKey("showcase.last-run")
            let value = Date().timeIntervalSince1970
            try await preferences.set(value, for: preferenceKey)
            let restored = try await preferences.get(Double.self, for: preferenceKey)

            let cache = DiskCache()
            let cacheKey = "showcase-payload"
            let payload = Data("disk-cache-sample".utf8)
            try await cache.save(cacheKey, payload)
            let cached = try await cache.load(cacheKey)
            try await cache.remove(cacheKey)
            await preferences.remove(preferenceKey)

            guard restored == value, cached == payload else {
                throw ShowcaseError.verificationFailed("storage mismatch")
            }
            return "UserDefaults و DiskCache: ذخیره، خواندن، exists/remove موفق"
        }
    }

    func runKeychain() async {
        await runStorageDemo {
            let keychain = KeychainStore(service: "com.modulartca.showcase")
            let key = StorageKey("demo-token")
            let token = Data("sample-token-not-production".utf8)
            try await keychain.save(token, for: key)
            guard await keychain.exists(key), try await keychain.load(for: key) == token else {
                throw ShowcaseError.verificationFailed("keychain mismatch")
            }
            try await keychain.delete(for: key)
            return "Keychain: ذخیره امن، exists، خواندن و حذف موفق"
        }
    }

    func runCoreData() async {
        await runStorageDemo {
            let stack = try await CoreDataStack(modelName: "Model", inMemory: true)
            let database = CoreDataStore(stack: stack)
            let facade = StorageFacade(
                preferences: UserDefaultsStore(),
                secure: KeychainStore(service: "com.modulartca.showcase.facade"),
                database: database
            )
            let record = ShowcaseRecord(id: "sample", title: "Core Data sample")
            try await facade.database.save(record, id: record.id)
            let restored = try await facade.database.fetch(ShowcaseRecord.self, id: record.id)
            try await facade.database.delete(ShowcaseRecord.self, id: record.id)
            guard restored == record else {
                throw ShowcaseError.verificationFailed("database mismatch")
            }
            return "StorageFacade و CoreData: save/fetch/delete موفق"
        }
    }

    private func postRequest(id: Int) -> NetworkRequest {
        NetworkRequest(baseURL: baseURL, path: "/posts/\(id)")
    }

    private func temporaryURL(name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: "ModularTCAShowcase", directoryHint: .isDirectory)
            .appending(path: name)
    }

    private func runNetworkDemo(_ operation: () async throws -> String) async {
        networkState = .running
        do {
            networkState = .success(try await operation())
        } catch {
            networkState = .failure(String(describing: error))
        }
    }

    private func runStorageDemo(_ operation: () async throws -> String) async {
        storageState = .running
        do {
            storageState = .success(try await operation())
        } catch {
            storageState = .failure(String(describing: error))
        }
    }
}

private struct ShowcaseRecord: Codable, Equatable, Sendable {
    let id: String
    let title: String
}

private enum ShowcaseError: Error {
    case verificationFailed(String)
}
