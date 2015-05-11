//
//  Keychain.swift
//  Keychain
//
//  Created by bakaneko on 22/03/2015.
//  Copyright (c) 2015 notbakaneko. All rights reserved.
//

import Foundation
import Security


private let ServiceName = "net.nekonyan.Keychain"

public enum QueryLimit {

}


public struct Keychain {
    private(set) var query = KeychainDictionaryType()
    private(set) var limit =  kSecMatchLimitOne

    public mutating func all() -> Keychain {
        limit = kSecMatchLimitAll
        return self
    }

    public mutating func one() -> Keychain {
        limit = kSecMatchLimitOne
        return self
    }

    public static func findOne<T: KeychainItemType>(predicate: T) -> KeychainQueryResult {
        var query = predicate.keychainDictionary
        query[kSecReturnAttributes.string] = true
        query[kSecMatchLimit.string] = kSecMatchLimitOne

        return find(query)
    }

    public static func findAll<T: KeychainItemType>(predicate: T) -> KeychainQueryResult {
        var query = predicate.keychainDictionary
        query[kSecReturnAttributes.string] = true
        query[kSecMatchLimit.string] = kSecMatchLimitAll

        return find(query)
    }

    public static func find(query: KeychainDictionaryType) -> KeychainQueryResult {
        var result: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(query, &result)
//        debugPrintln(status)
//        debugPrintln(result)
        let queryResult = KeychainQueryResult(status: status, result: result?.takeUnretainedValue())
        return queryResult
    }

    public mutating func query(query: KeychainDictionaryType) -> Keychain {
        self.query = query
        return self
    }

//    public func map<U>(@noescape f: (T) -> U) -> U? {
//        var result: Unmanaged<AnyObject>?
//        let status = SecItemCopyMatching(query, &result)
//        debugPrintln(status)
//        debugPrintln(result)
//        return result?.takeUnretainedValue()
//    }

    public static func add<T: KeychainItemType>(item: T) -> KeychainQueryResult {
        var result: Unmanaged<AnyObject>?
        let status = SecItemAdd(item.keychainDictionary, &result)

        return KeychainQueryResult(status: status, result: result?.takeUnretainedValue())
    }

    public static func update<T: KeychainItemType>(item: T) -> KeychainQueryResult {
        var attributes = item.keychainDictionary
        attributes.removeValueForKey(kSecClass.string)
        var result: Unmanaged<AnyObject>?
        let status = SecItemUpdate(item.keychainDictionary, attributes)

        return KeychainQueryResult(status: status, result: result?.takeUnretainedValue())
    }


    public func map() -> AnyObject? {
        var result: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(query, &result)
        debugPrintln(status)
        debugPrintln(result)
        return result?.takeUnretainedValue()
    }
}


public struct KeychainQueryResult {
    public let status: OSStatus
    public let result: AnyObject?
}
