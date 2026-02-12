import Foundation

// 将 Response 模型放在独立文件中，彻底避免 MainActor 隔离问题
struct HResponse: Codable, Sendable {
    var headers: RespHeaders?
    var origin: String?
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case headers, origin, url
    }
    
    // 显式实现 init(from:) 并标记为 nonisolated
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.headers = try container.decodeIfPresent(RespHeaders.self, forKey: .headers)
        self.origin = try container.decodeIfPresent(String.self, forKey: .origin)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
    }
    
    // 显式实现 encode(to:) 并标记为 nonisolated
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(headers, forKey: .headers)
        try container.encodeIfPresent(origin, forKey: .origin)
        try container.encodeIfPresent(url, forKey: .url)
    }
}

struct RespHeaders: Codable, Sendable {
    var Accept: String?
    var Host: String?
    var Priority: String?
    
    enum CodingKeys: String, CodingKey {
        case Accept, Host, Priority
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.Accept = try container.decodeIfPresent(String.self, forKey: .Accept)
        self.Host = try container.decodeIfPresent(String.self, forKey: .Host)
        self.Priority = try container.decodeIfPresent(String.self, forKey: .Priority)
    }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(Accept, forKey: .Accept)
        try container.encodeIfPresent(Host, forKey: .Host)
        try container.encodeIfPresent(Priority, forKey: .Priority)
    }
}
