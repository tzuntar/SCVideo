//
//  KeychainHelper.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 3/23/23.
//

import Foundation

private final class KeychainAccess {
    
    static func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        if (status == errSecSuccess) {
            return
        }
        if status == errSecDuplicateItem {  // item already exist, thus update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(query, attributesToUpdate)
        } else {
            print("Failed to save data to the keychain: \(status)")
        }
    }
    
    static func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return (result as? Data)
    }
    
    static func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        SecItemDelete(query)
    }
    
}

final class KeychainHelper {
    
    static let standard = KeychainHelper()
    private init() {}
    
    func save<T>(_ item: T, service: String, account: String) where T : Codable {
        do {
            // encode the data as JSON and save it in the keychain
            let data = try JSONEncoder().encode(item)
            KeychainAccess.save(data, service: service, account: account)
        } catch {
            assertionFailure("Failed to encode keychain item: \(error)")
        }
    }
    
    func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
        guard let data = KeychainAccess.read(service: service, account: account) else {
            return nil
        }
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Failed to decode keychain item: \(error)")
            return nil
        }
    }
    
}
