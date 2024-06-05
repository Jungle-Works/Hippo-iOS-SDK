//
//  CryptoJS.swift
//
//  Created by Emartin on 2015-08-25.
//  Copyright (c) 2015 Emartin. All rights reserved.
//

import Foundation
import JavaScriptCore
import CryptoKit

private var cryptoJScontext = JSContext()

class CryptoJS{

    class AES: CryptoJS{

        fileprivate var encryptFunction: JSValue!
        fileprivate var decryptFunction: JSValue!

        override init(){
            super.init()

            // Retrieve the content of aes.js
            let cryptoJSpath = FuguFlowManager.bundle?.path(forResource: "aes", ofType: "js")
                //Bundle.main.path(forResource: "aes", ofType: "js")

            if(( cryptoJSpath ) != nil){
                do {
                    let cryptoJS = try String(contentsOfFile: cryptoJSpath!, encoding: String.Encoding.utf8)
                    print("Loaded aes.js")

                    // Evaluate aes.js

                        _ = cryptoJScontext?.evaluateScript(cryptoJS)

                        // Reference functions
                        self.encryptFunction = cryptoJScontext?.objectForKeyedSubscript("encrypt")
                        self.decryptFunction = cryptoJScontext?.objectForKeyedSubscript("decrypt")


                }
                catch {
                    print("Unable to load aes.js")
                }
            }else{
                print("Unable to find aes.js")
            }

        }

        func encrypt(_ message: String, password: String,options: Any?=nil)->String {
            if let unwrappedOptions: Any = options {
                return "\(encryptFunction.call(withArguments: [message, password, unwrappedOptions])!)"
            }else{
                return "\(encryptFunction.call(withArguments: [message, password])!)"
            }
        }
        func decrypt(_ message: String, password: String,options: Any?=nil)->String {
            if let unwrappedOptions: Any = options {
                return "\(decryptFunction.call(withArguments: [message, password, unwrappedOptions])!)"
            }else{
                return "\(decryptFunction.call(withArguments: [message, password])!)"
            }
        }

    }

}




class AESManager {
    static let shared = AESManager()
    // Function to encrypt data using AES
    func encrypt(data: [Data], key: SymmetricKey) throws -> Data {
        // Use AES-GCM for authenticated encryption
        let combination = data.reduce(Data()) { partialResult, newData in
            return partialResult + newData
        }

        let sealedBox = try AES.GCM.seal(combination, using: key)
        // Return the ciphertext
        return sealedBox.combined!
    }

    // Function to decrypt data using AES
    func decrypt(data: [Data], key: SymmetricKey) throws -> Data {
        // Attempt to open the sealed box
        let combination = data.reduce(Data()) { partialResult, newData in
            return partialResult + newData
        }
        let sealedBox = try AES.GCM.SealedBox(combined: combination)
        // Decrypt the data
        return try AES.GCM.open(sealedBox, using: key)
    }

    // Generate a random AES key
    func generateAESKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256) // 256-bit key
    }
}
