import Foundation

struct HackerNewsPost: Identifiable, Decodable {
    var title: String
    var url: String?
    let id = UUID()

    enum CodingKeys: String, CodingKey {
        case title
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}
