//
//  APIRequest.swift
//  Life-FormSearch
//
//  Created by Peter Sivak on 11/18/24.
//

import Foundation

protocol APIRequest {
    associatedtype Response
    
    var urlRequest: URLRequest { get }
    func decodeResponse(data: Data) throws -> Response
}

enum APIRequestError: Error {
    case itemNotFound
}
