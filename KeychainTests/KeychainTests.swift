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
    var password = NSUUID().UUIDString
    var genericPassword: GenericPassword!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let genericPasswordUniqueProperty = (account: "account-name", service: serviceName)
        genericPassword = GenericPassword(genericPasswordUniqueProperty)

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func test_GenericPassword() {
        // clear field
        func clear() {
            var result: Unmanaged<AnyObject>?
            let query = genericPassword.keychainDictionary
            let status = SecItemDelete(query)
        }

        func set() {
            // set
            genericPassword.password = self.password
            let result = Keychain.add(genericPassword)
            XCTAssert(result.status == 0, "Expected 0, got \(result.status)")
        }

        func find() {
            genericPassword.includeData = true
            let result = Keychain.findOne(genericPassword)
            let password = result.result?.password
            XCTAssert(self.password == password, "Expected \(password) to equal \(self.password)")
            XCTAssert(genericPassword.password == password, "Expected \(password) to equal \(genericPassword.password)")
        }


        clear()
        set()
        find()
    }

    func test_findGenericPassword() {
        let genericPasswordUniqueProperty = (account: "account-name", service: serviceName)
        var genericPassword = GenericPassword(genericPasswordUniqueProperty)
        genericPassword.includeData = true


        let findResult = Keychain.findOne(genericPassword)
        let password = findResult.result?.password



        var matchResult: Unmanaged<AnyObject>?
        var query = genericPassword.keychainDictionary
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let status = SecItemCopyMatching(query, &matchResult)
        let matchResultValue = matchResult?.takeUnretainedValue() as? NSDictionary
        debugPrintln(matchResultValue)
        debugPrintln(status)


        XCTAssert(self.password == password, "Expected \(password) to equal \(self.password)")
    }

    func test_KeychainQuery() {
        var query = [String:AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitAll

        let result = Keychain.find(query)

        debugPrintln(result.status)
        debugPrintln(result.result)
    }

}

