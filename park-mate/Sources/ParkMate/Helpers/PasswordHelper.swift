// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation
import CryptoKit
import CommonCrypto

struct PasswordHelper {
    static func hashPassword(_ password: String, salt: Data) -> Data? {
        let passwordData = Data(password.utf8)
        var derivedKey = Data(count: 32) // 256-bit key

        // Create a local copy of 'derivedKey' to prevent overlapping access
        var localDerivedKey = derivedKey

        let result = localDerivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password,
                    passwordData.count,
                    saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    100_000, // Number of iterations
                    derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress,
                    derivedKey.count
                )
            }
        }

        if result == kCCSuccess {
            derivedKey = localDerivedKey
            return derivedKey
        } else {
            return nil
        }
    }

    static func generateSalt(length: Int = 16) -> Data? {
        var salt = Data(count: length)
        let result = salt.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        return result == errSecSuccess ? salt : nil
    }
}
#endif
