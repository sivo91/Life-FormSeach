import Foundation

struct EOLItem: Codable {
    var id: Int
    var scientificName: String
    var commonName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case scientificName = "title"
        case commonName = "content"
    }
}

struct SearchResponse: Codable {
    var results: [EOLItem]
}
