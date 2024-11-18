
import Foundation

struct TaxonConcept: Codable {
    var accordingTo: String?
    var identifier: Int
    
    enum CodingKeys: String, CodingKey {
        case accordingTo = "nameAccordingTo"
        case identifier
    }
}

struct Agent: Codable {
    var fullName: String?
    var role: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case role
    }
}

struct DataObject: Codable {
    var mimeType: String?
    var agents: [Agent]?
    var rightsHolder: String?
    var eolMediaURL: URL?
    var license: String?

}

struct EOLItemDetails: Codable {
    var scientificName: String?
    var dataObjects: [DataObject]?
    var taxonConcepts: [TaxonConcept]?
}

struct EOLItemDetail: Codable {
    var details: EOLItemDetails
    
    enum CodingKeys: String, CodingKey {
        case details = "taxonConcept"
    }
}

