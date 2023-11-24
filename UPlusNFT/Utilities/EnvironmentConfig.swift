//
//  EnvironmentConfig.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/11.
//

import Foundation

public enum EnvironmentConfig {
    enum Keys: String {
        case uplusContractAddress = "UPLUS_NFT_CONTRACT_ADDRESS_VALUE"
        case xNodeId = "X_NODE_ID_VALUE"
        case xKeyId = "X_KEY_ID_VALUE"
        case xKeySecretValue = "X_KEY_SECRET_VALUE"
        case uplusAccessCode = "UPLUS_NFT_ACCESS_CODE"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let uplusContractAddress: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.uplusContractAddress.rawValue] as? String else {
            fatalError("uplusContractAddress not set in plist for this environment")
        }
        
        return value
    }()
    
    static let xNodeId: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.xNodeId.rawValue] as? String else {
            fatalError("xNodeId not set in plist for this environment")
        }
        
        return value
    }()
    
    static let xKeyId: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.xKeyId.rawValue] as? String else {
            fatalError("xKeyId not set in plist for this environment")
        }
        
        return value
    }()
    
    static let xKeySecretValue: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.xKeySecretValue.rawValue] as? String else {
            fatalError("xKeySecretValue not set in plist for this environment")
        }
        
        return value
    }()
    
    static let uplusAccessCode: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.uplusAccessCode.rawValue] as? String else {
            fatalError("uplusAccessCode not set in plist for this environment")
        }
        
        return value
    }()
    
}
