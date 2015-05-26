//
//  KeychainTests.swift
//  KeychainTests
//
//  Created by bakaneko on 22/03/2015.
//  Copyright (c) 2015 notbakaneko. All rights reserved.
//

import Foundation
import XCTest
import Keychain

let serviceName = "net.nekonyan.Keychain-test"
class KeychainTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func test_GenericPassword() {
        let genericPasswordUniqueProperty = (account: "account-name", service: serviceName)
        var genericPassword = GenericPassword(genericPasswordUniqueProperty)


        var result: Unmanaged<AnyObject>?
        let query = genericPassword.keychainDictionary
        let status = SecItemCopyMatching(query, &result)
        debugPrintln(result)
        debugPrintln(status)
    }

    func test_KeychainQuery() {
        var query = [String:AnyObject]()
        query[kSecClass as String] = kSecClassInternetPassword
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitAll

        let result: KeychainQueryResult = Keychain.find(query)
    }

}

