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

    public static func find<T: KeychainItemType>(predicate: T) -> AnyObject? {
        return find(predicate.keychainDictionary)
    }

    public static func find(query: KeychainDictionaryType) -> AnyObject? {
        var result: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(query, &result)
        debugPrintln(status)
        debugPrintln(result)
        return result?.takeUnretainedValue()
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


    public func map() -> AnyObject? {
        var result: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(query, &result)
        debugPrintln(status)
        debugPrintln(result)
        return result?.takeUnretainedValue()
    }
}
