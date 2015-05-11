//
//  KeychainItem.swift
//  Keychain
//
//  Created by bakaneko on 23/03/2015.
//  Copyright (c) 2015 notbakaneko. All rights reserved.
//

import Foundation
import Security

extension CFStringRef {
    var string: String { return self as! String }
}

public typealias KeychainDictionaryType = [String:AnyObject]


public enum KeyAlgorithm : String {
    case EC = "EllipticCurve"
    case RSA = "RSA"

    public var value: CFStringRef {
        switch self {
        case EC: return kSecAttrKeyTypeEC
        case RSA: return kSecAttrKeyTypeRSA
        }
    }
}


public struct GenericKeychainItem: KeychainItemType {
    public typealias UniqueProperty = (service: String, account: String)
    public var service: String
    public var group: String?

    public var label: String?
    public var description: String?
    public var comment: String?
    public var data: NSData

    public init(service: String, data: NSData, group: String? = nil) {
        self.service = service
        self.data = data
        self.group = group
    }

    public var keychainDictionary: KeychainDictionaryType {
        var dictionary = KeychainDictionaryType()

        return dictionary
    }
}


public struct GenericPassword: KeychainItemType {
    // kSecAttrAccount, kSecAttrService
    public typealias UniqueProperty = (account: String, service: String)
    public var unique: UniqueProperty
    public var itemDescription: String?
    public var comment: String?

    public init(_ unique: UniqueProperty) {
        self.unique = unique
    }

    public var keychainDictionary: KeychainDictionaryType {
        var dictionary = KeychainDictionaryType()
        dictionary[kSecClass.string] = kSecClassGenericPassword

        dictionary[kSecAttrAccount.string] = unique.account
        dictionary[kSecAttrService.string] = unique.service

        dictionary[kSecAttrDescription.string] = itemDescription
        dictionary[kSecAttrComment.string] = comment

        return dictionary
    }
}

public struct InternetPassword: KeychainItemType {
    // kSecAttrAccount, kSecAttrSecurityDomain, kSecAttrServer, kSecAttrProtocol, kSecAttrAuthenticationType, kSecAttrPort, kSecAttrPath
    public typealias UniqueProperty = (account: String, domain: String, server: String, protocolType: String, authenticationType: String, port: Int, path: String)
    public var unique: UniqueProperty
    public var itemDescription: String?
    public var comment: String?

    public var keychainDictionary: KeychainDictionaryType {
        var dictionary = KeychainDictionaryType()
        dictionary[kSecClass.string] = kSecClassInternetPassword

        dictionary[kSecAttrAccount.string] = unique.account
        dictionary[kSecAttrSecurityDomain.string] = unique.domain
        dictionary[kSecAttrServer.string] = unique.server
        dictionary[kSecAttrProtocol.string] = unique.protocolType
        dictionary[kSecAttrAuthenticationType.string] = unique.authenticationType
        dictionary[kSecAttrPort.string] = unique.port
        dictionary[kSecAttrPath.string] = unique.path

        dictionary[kSecAttrDescription.string] = itemDescription
        dictionary[kSecAttrComment.string] = comment

        return dictionary
    }
    
}


public struct Key: KeychainItemType {
    // kSecAttrApplicationLabel, kSecAttrApplicationTag, kSecAttrKeyType, kSecAttrKeySizeInBits, kSecAttrEffectiveKeySize
    public typealias UniqueProperty = (label: String, tag: String, algorithm: KeyAlgorithm, bitSize: Int, effectiveKeySize: Int)
    public var unique: UniqueProperty
    public var itemDescription: String?
    public var comment: String?

    public var keychainDictionary: KeychainDictionaryType {
        var dictionary = KeychainDictionaryType()
        dictionary[kSecClass.string] = kSecClassKey

        dictionary[kSecAttrApplicationLabel.string] = unique.label
        dictionary[kSecAttrApplicationTag.string] = unique.tag
        dictionary[kSecAttrKeyType.string] = unique.algorithm.value
        dictionary[kSecAttrKeySizeInBits.string] = unique.bitSize
        dictionary[kSecAttrEffectiveKeySize.string] = unique.effectiveKeySize

        dictionary[kSecAttrDescription.string] = itemDescription
        dictionary[kSecAttrComment.string] = comment

        return dictionary
    }
}


//extension Dictionary {
//    subscript(key: CFStringRef) -> Value? {
//        get {
//            return self[key as! String]
//        }
//
//        set(newValue) {
//            self[key as! String] = newValue
//        }
//    }
//}

