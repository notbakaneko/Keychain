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
    var string: String { return self as String }
}

// laziness operator
infix operator => { }
func => <T>(lhs: AnyObject?, inout rhs: T?) {
    rhs = lhs as? T
}

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

private func stringFromValueData(dictionary: KeychainDictionaryType) -> String? {
    if let data = dictionary[kSecValueData.string] as? NSData {
        return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
    } else {
        return nil
    }
}

public struct GenericPassword: KeychainItemType, KeychainItemWithData {
    // kSecAttrAccount, kSecAttrService
    public typealias UniqueProperty = (account: String, service: String)
    public var unique: UniqueProperty
    public var itemDescription: String?
    public var comment: String?
    public var password: String?

    public var includeData = false

    public init(_ unique: UniqueProperty) {
        self.unique = unique
    }

    public init?(object: AnyObject?) {
        if let dictionary = object as? KeychainDictionaryType {
            self.init(dictionary: dictionary)
        } else {
            return nil
        }
    }

    public init?(dictionary: KeychainDictionaryType) {
        if let account = dictionary[kSecAttrAccount.string] as? String, service = dictionary[kSecAttrService.string] as? String {
            unique = UniqueProperty(account, service)
        } else {
            return nil
        }

        dictionary[kSecAttrDescription.string] => itemDescription
        dictionary[kSecAttrComment.string] => comment

        password = stringFromValueData(dictionary)
    }

    public var keychainDictionary: KeychainDictionaryType {
        var dictionary = KeychainDictionaryType()
        dictionary[kSecClass.string] = kSecClassGenericPassword

        dictionary[kSecAttrAccount.string] = unique.account
        dictionary[kSecAttrService.string] = unique.service

        dictionary[kSecAttrDescription.string] = itemDescription
        dictionary[kSecAttrComment.string] = comment

        dictionary[kSecValueData.string] = password?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if includeData {
            dictionary[kSecReturnData.string] = true
        }

        return dictionary
    }
}

public struct InternetPassword: KeychainItemType, KeychainItemWithData {
    // kSecAttrAccount, kSecAttrSecurityDomain, kSecAttrServer, kSecAttrProtocol, kSecAttrAuthenticationType, kSecAttrPort, kSecAttrPath
    public typealias UniqueProperty = (account: String, domain: String, server: String, protocolType: String, authenticationType: String, port: Int, path: String)
    public var unique: UniqueProperty
    public var itemDescription: String?
    public var comment: String?
    public var password: String?

    public var includeData = false

    public init?(object: AnyObject?) {
        if let dictionary = object as? KeychainDictionaryType {
            self.init(dictionary: dictionary)
        } else {
            return nil
        }
    }

    public init?(dictionary: KeychainDictionaryType) {
        if let account = dictionary[kSecAttrAccount.string] as? String,
            domain = dictionary[kSecAttrSecurityDomain.string] as? String,
            server = dictionary[kSecAttrServer.string] as? String,
            protocolType = dictionary[kSecAttrProtocol.string] as? String,
            authenticationType = dictionary[kSecAttrAuthenticationType.string] as? String,
            port = dictionary[kSecAttrPort.string] as? Int,
            path = dictionary[kSecAttrPath.string] as? String {
                unique = UniqueProperty(account, domain, server, protocolType, authenticationType, port, path)
        } else {
            return nil
        }

        dictionary[kSecAttrDescription.string] => itemDescription
        dictionary[kSecAttrComment.string] => comment

        password = stringFromValueData(dictionary)
    }

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

        dictionary[kSecValueData.string] = password?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if includeData {
            dictionary[kSecReturnData.string] = true
        }

        return dictionary
    }
    
}


public struct Key: KeychainItemType {
    // kSecAttrApplicationLabel, kSecAttrApplicationTag, kSecAttrKeyType, kSecAttrKeySizeInBits, kSecAttrEffectiveKeySize
    public typealias UniqueProperty = (label: String, tag: String, algorithm: KeyAlgorithm, bitSize: Int, effectiveKeySize: Int)
    public var unique: UniqueProperty
    public var itemDescription: String?
    public var comment: String?

    public init?(object: AnyObject?) {
        if let dictionary = object as? KeychainDictionaryType {
            self.init(dictionary: dictionary)
        } else {
            return nil
        }
    }

    public init?(dictionary: KeychainDictionaryType) {
        if let label = dictionary[kSecAttrApplicationLabel.string] as? String,
            tag = dictionary[kSecAttrApplicationTag.string] as? String,
            keyType = dictionary[kSecAttrKeyType.string] as? String,
            algorithm = KeyAlgorithm(rawValue: keyType),
            bitSize = dictionary[kSecAttrKeySizeInBits.string] as? Int,
            effectiveKeySize = dictionary[kSecAttrEffectiveKeySize.string] as? Int {
                unique = UniqueProperty(label, tag, algorithm, bitSize, effectiveKeySize)
        } else {
            return nil
        }

        dictionary[kSecAttrDescription.string] => itemDescription
        dictionary[kSecAttrComment.string] => comment
    }

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
