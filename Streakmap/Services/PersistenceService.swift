import Foundation

enum PersistenceService {
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: data)
    }

    static func saveString(_ value: String?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func loadString(forKey key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    static func saveBool(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func loadBool(forKey key: String) -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }
}
