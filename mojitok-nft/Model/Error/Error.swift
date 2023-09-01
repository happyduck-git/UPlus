//
//  Error.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/27.
//

import Foundation

enum G3ErrorKind {
    case invalidToken
    case expiredToken
    case requestInvalid
    case serverError
    case fail
    
    var name: String {
        switch self {
        case .invalidToken:
            return "Invalid Token"
        case .expiredToken:
            return "Expired Token"
        case .requestInvalid:
            return "Request Invalid"
        case .serverError:
            return "Server Error"
        case .fail:
            return "General Fail"
        }
    }
    
    var description: String {
        switch self {
        case .invalidToken:
            return "Token is invalid"
        case .expiredToken:
            return "Token is expired"
        case .requestInvalid:
            return "Request is invalid"
        case .serverError:
            return "Server error"
        case .fail:
            return "Fail of general"
        }
    }
}

struct G3Error: Error {
    let name: String
    let kind: G3ErrorKind
    let description: String
    let moreInfo: String?
    
    init(kind: G3ErrorKind) {
        self.name = kind.name
        self.kind = kind
        self.description = kind.description
        self.moreInfo = nil
    }
    
    init(kind: G3ErrorKind, moreInfo: String) {
        self.name = kind.name
        self.kind = kind
        self.description = kind.description
        self.moreInfo = moreInfo
    }
}
