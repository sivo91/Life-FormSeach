//
//  EOLHierarchy.swift
//  Life-FormSearch
//
//  Created by Peter Sivak on 11/18/24.
//


import Foundation

struct Ancestor: Codable {
    var scientificName: String
    var taxonRank: String?
}
struct EOLHierarchy: Codable {
    var ancestors: [Ancestor]?
    
}

