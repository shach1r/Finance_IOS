import Foundation

final class LocalStore {

    private let folder: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        folder = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]

        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    private func url(_ name: String) -> URL {
        folder.appendingPathComponent(name + ".json")
    }

    func load<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        let path = url(name)
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func save<T: Encodable>(_ name: String, _ value: T) {
        do {
            let data = try encoder.encode(value)
            try data.write(to: url(name), options: [.atomic])
        } catch {
            print("LocalStore save failed for \(name): \(error)")
        }
    }
}
