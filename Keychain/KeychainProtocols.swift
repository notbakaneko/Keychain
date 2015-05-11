//
//  KeychainProtocols.swift
//  Keychain
//
//  Created by bakaneko on 23/03/2015.
//  Copyright (c) 2015 notbakaneko. All rights reserved.
//

import Foundation

public typealias KeychainDictionaryType = [String:AnyObject]

public protocol KeychainItemType {
    typealias UniqueProperty
    var keychainDictionary: KeychainDictionaryType { get }

    init?(dictionary: KeychainDictionaryType)
    init?(object: AnyObject?)
}

public protocol KeychainItemWithData {
    var includeData: Bool { get }
}

public protocol ICloudSyncable {
    var syncable: Bool { get set }
    func syncable(flag: Bool) -> Self
}


// MARK:- Keychain item data conversion
public protocol GenericKeychainItemDataConvertible {
    var keychainItemData: NSData? { get }
}

extension NSData: GenericKeychainItemDataConvertible {
    public var keychainItemData: NSData? {
        return self
    }
}

extension String : GenericKeychainItemDataConvertible {
    public var keychainItemData: NSData? {
        return self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    }
}
