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

    public static func findOne<T: KeychainItemType>(predicate: T) -> KeychainQueryResult<T> {
        var query = predicate.keychainDictionary
        query[kSecReturnAttributes.string] = true
        query[kSecMatchLimit.string] = kSecMatchLimitOne

        let result = find(query)
        return KeychainQueryResult(status: result.status, result: T(object: result.result))
    }

    public static func findAll<T: KeychainItemType>(predicate: T) -> KeychainQueryResult<[T]> {
        var query = predicate.keychainDictionary
        query[kSecReturnAttributes.string] = true
        query[kSecMatchLimit.string] = kSecMatchLimitAll

        let result = find(query)
        var array = [T]()

        if let queryResults = result.result as? [AnyObject] {
            for item in queryResults {
                if let x = T(object: item) {
                    array.append(x)
                }
            }
        }

        return KeychainQueryResult(status: result.status, result: array)
    }

    public static func find(query: KeychainDictionaryType) -> KeychainQueryResult<AnyObject> {
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

    public static func add<T: KeychainItemType>(item: T) -> KeychainQueryResult<T> {
        var result: Unmanaged<AnyObject>?
        let status = SecItemAdd(item.keychainDictionary, &result)

        return KeychainQueryResult(status: status, result: T(object: result?.takeUnretainedValue()))
    }

    public static func update<T: KeychainItemType>(item: T) -> KeychainQueryResult<T> {
        var attributes = item.keychainDictionary
        attributes.removeValueForKey(kSecClass.string)
        var result: Unmanaged<AnyObject>?
        let status = SecItemUpdate(item.keychainDictionary, attributes)

        return KeychainQueryResult(status: status, result: T(object: result?.takeUnretainedValue()))
    }

    public static func addOrUpdate<T: KeychainItemType>(item: T) -> KeychainQueryResult<T> {
        let findResult = findOne(item)
        if findResult.status == 0 {
            // update
            return update(item)
        } else {
            // add
            return add(item)
        }
    }

    public static func delete<T: KeychainItemType>(item: T) -> KeychainQueryResult<T> {
        let result = delete(item.keychainDictionary)
        return KeychainQueryResult(status: result.status, result: T(object: result.result))
    }

    public static func delete(query: KeychainDictionaryType) -> KeychainQueryResult<AnyObject> {
        let status = SecItemDelete(query)
        return KeychainQueryResult(status: status, result: nil)
    }


    public func map() -> AnyObject? {
        var result: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(query, &result)
        debugPrintln(status)
        debugPrintln(result)
        return result?.takeUnretainedValue()
    }
}



public struct KeychainQueryResult<T> {
    public let status: OSStatus
    public let result: T?
}
