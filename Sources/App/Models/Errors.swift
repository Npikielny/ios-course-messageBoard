//
//  Errors.swift
//  
//
//  Created by Noah Pikielny on 3/23/22.
//

import Vapor

enum RouteError: AbortError, CustomStringConvertible {
    case notFound
    case partialInformation(String)
    case unsupportedMediaType
    case unauthorized
    
    var description: String {
        switch self {
            case .notFound: return "Not Found"
            case .partialInformation(let string): return "Missing information: \(string)"
            case .unsupportedMediaType: return "Unsupported media type–probably an invalid JSON"
            case .unauthorized: return "Unauthorized"
        }
    }
    
    var status: HTTPResponseStatus {
        switch self {
            case .notFound: return HTTPResponseStatus(statusCode: 404)
            case .partialInformation(_): return HTTPResponseStatus(statusCode: 400)
            case .unsupportedMediaType: return HTTPResponseStatus(statusCode: 400)
            case .unauthorized: return HTTPResponseStatus(statusCode: 401)
        }
    }
}
