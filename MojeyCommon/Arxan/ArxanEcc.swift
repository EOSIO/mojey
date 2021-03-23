//
//  Arxan.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/26/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class ArxanEcc {

    static func sign(message: Data, key: TFIT_key_iECDSASfastP256_t) throws -> EcdsaSignature {

        var context = TFIT_ctx_iECDSASfastP256_t()
        var key = key

        let rPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        let sPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        var rBytesWritten = UInt32()
        //var buffer = Data(repeating: 0, count: 256)
        var sBytesWritten = UInt32()


        var result = TFIT_init_wbecc_dsa_deterministic_nonce_iECDSASfastP256(
            &context,                  // the ECDSA sign context structure
            &key,                       // the keypair
            WBECC_SHA2_256               // use SHA-256 for the hash function
        )

        guard result == 0 else {
            throw SCError(reason: "TFIT_init_wbecc_dsa_deterministic_nonce_iECDSASfastP256() failed with error: \(result)")
        }

        let messageBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: message.count)
        message.copyBytes(to: messageBytes, count: message.count)

        result = TFIT_update_wbecc_dsa_iECDSASfastP256(
            &context, // the ECDSA sign context structure
            messageBytes,         // the message to sign
            UInt32(message.count)  // the size of the message
        )

        guard result == 0 else {
            throw SCError(reason: "TFIT_update_wbecc_dsa_iECDSASfastP256() failed with error: \(result)")
        }

        result = TFIT_final_sign_wbecc_dsa_iECDSASfastP256(
            &context,  // the ECDSA sign context structure
            rPointer,                // the signature's R value
            32,        // size of the R buffer
            &rBytesWritten, // number of bytes written to R
            sPointer,                // the signature's S value
            32,        // size of the S buffer
            &sBytesWritten  // number of bytes written to S
        )

        guard result == 0 else {
            throw SCError(reason: "TFIT_final_sign_wbecc_dsa_iECDSASfastP256() failed with error: \(result)")
        }

        let r = Data(bytes: rPointer, count: 32)
        let s = Data(bytes: sPointer, count: 32)

        rPointer.deallocate()
        sPointer.deallocate()

        guard let sig = EcdsaSignature(der: EcdsaSignature(r: r, s: s).der) else {
            throw SCError(reason: "Cannot create signature from r:\(r.hex) s:\(s.hex)")
        }
        
        print("\n===ARXAN==========================================================")
        //print(r.hex)
        //print(s.hex)
        print("r:\(sig.r.hex)")
        print("s:\(sig.s.hex)")
        print(sig.der.hex)

        guard try verify(signature: sig.der, message: message) else {
            throw SCError(reason: "Fail")
        }
        return sig
    }


    static func verify(signature: Data, message: Data) throws -> Bool {
        print("\n==Attempt Arxan Verify======================================")
        let pubKey = try Data(hex: "04327e3145753f30cfc4c266e094b8d22e080a5c506d06012686c1b32cbcf611ae321cd63bcead04edd3100cc998731b165f7485b8559efe83ec49fcc6eebbeb72")
        guard try MojeyKeyManager.default.keychain.verifyWithEllipticCurvePublicKey(keyData: pubKey, message: message, signature: signature) else {
            throw SCError(reason: "Fail")
        }

        print("Arxan Apple Verify passed")
        let key0 = try EccRecoverKey.recoverPublicKey(signatureDer: signature, message: message.sha256, recid: 0)
        let key1 = try EccRecoverKey.recoverPublicKey(signatureDer: signature, message: message.sha256, recid: 1)
        print(key0.hex)
        print(key1.hex)

        guard key0 == pubKey || key1 == pubKey else {
            throw SCError(reason: "Fail")
        }
        print("Arxan Verify passed")
        print("=========================================\n")
        return true
    }

    
    static func encrypt(message: Data, key: TFIT_key_iECEGEfastP256_t) throws -> Data {

        var context = TFIT_ctx_iECEGEfastP256_t()
        var key = key

        var result = TFIT_init_wbecc_eg_iECEGEfastP256(
            &context,
            &key,
            random_data
        )
        guard result == 0 else {
            throw SCError(reason: "TFIT_init_wbecc_eg_iECEGEfastP256() failed with error: \(result)")
        }

        print(message.hex)
        let pc = 28 - message.count % 28
        print(pc)
        let padding = Data(repeating: 0, count: pc)
        let paddedMessage = message + padding
        print(paddedMessage.count)

        let plaintextLength = paddedMessage.count
        let plaintextPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: plaintextLength)
        paddedMessage.copyBytes(to: plaintextPointer, count: plaintextLength)

        let ciphertextLength = paddedMessage.count * 5
        let ciphertextPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: ciphertextLength)
        var runningTotal: UInt32 = 0

        /*
          * Update the context object with the plaintext. The total plaintext
          * length over all calls to this update API must be an even multiple of
          * the input block size, which is 4 bytes less than the curve size.
          * In this example using P256 the input block size is therefore 28.
        */
        result = TFIT_update_wbecc_eg_iECEGEfastP256(
            &context,                   // the initialized context object
            plaintextPointer,           // buffer holding the plaintext
            UInt32(plaintextLength),    // its length
            ciphertextPointer,          // buffer to hold the resulting ciphertext
            UInt32(ciphertextLength),   // its length
            &runningTotal               // the number of bytes written to ciphertext
        )
        guard result == 0 else {
            throw SCError(reason: "TFIT_init_wbecc_eg_iECEGEfastP256() failed with error: \(result)")
        }

        let ciphertext = Data(bytes: ciphertextPointer, count: Int(runningTotal))
        print(ciphertext)
        print(runningTotal)

        /*
         * Call TFIT_final_wbecc_eg_iECEGEfastP256 to cleanup memory and make
         * sure there is no additional data leftover in the internal buffer. This
         * API will not produce ciphertext even though there is a parameter for it.
         */
        result = TFIT_final_wbecc_eg_iECEGEfastP256(
            &context,                       // the updated context object
            ciphertextPointer,     // a non-null dummy buffer
            UInt32(ciphertextLength),  // its length, it can be zero
            &runningTotal  // the number of bytes written to ciphertext, zero
        )

        plaintextPointer.deallocate()
        ciphertextPointer.deallocate()

        return ciphertext
    }


    static func decrypt(message: Data, key: TFIT_key_iECEGDfastP256_t) throws -> Data {

        var context = TFIT_ctx_iECEGDfastP256_t()
        var key = key

        var result = TFIT_init_wbecc_eg_iECEGDfastP256(
            &context,
            &key
        )
        guard result == 0 else {
            throw SCError(reason: "TFIT_init_wbecc_eg_iECEGDfastP256() failed with error: \(result)")
        }

        let ciphertextLength = message.count
        let ciphertextPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: ciphertextLength)
        message.copyBytes(to: ciphertextPointer, count: ciphertextLength)

        let plaintextLength = ciphertextLength / 4
        let plaintextPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: plaintextLength)
        var runningTotal: UInt32 = 0



        /*
         * Update the TransformIT context with one block of previously computed
         * ciphertext and store the decrypted text in the plaintext buffer.
         */
        result = TFIT_update_wbecc_eg_iECEGDfastP256(
            &context,                           // the initialized context object
            ciphertextPointer,                  // ciphertext to decrypt
            128,                                // amount to decrypt
            plaintextPointer,                   // plaintext buffer offset.
                // Divide by 4 since plaintext is 1/4th size of ciphertext
            UInt32(plaintextLength),                    // length of the plaintext buffer
            &runningTotal                       // record how many bytes we wrote out
        )
        guard result == 0 else {
            throw SCError(reason: "TFIT_init_wbecc_eg_iECEGDfastP256() failed with error: \(result)")
        }

        let plainText = Data(bytes: plaintextPointer, count: Int(runningTotal)).dropFirst(4)
        print(plainText)
        print(runningTotal)


        /*
         * Call TFIT_final_wbecc_eg_iECEGDfastP256 to cleanup memory and make
         * sure there is no additional data leftover in the internal buffer. This
         * API will not produce plaintext even though there is a parameter for it.
         */
        result = TFIT_final_wbecc_eg_iECEGDfastP256(
            &context,                          // the updated context object
            plaintextPointer,  // a non-null dummy buffer
            UInt32(plaintextLength), // its length, it can be zero
            &runningTotal // the number of bytes written to plaintext, zero
        )

        plaintextPointer.deallocate()
        ciphertextPointer.deallocate()

        return plainText
    }

}
