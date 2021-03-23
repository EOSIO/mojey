//
//  ReceiptValidator.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 12/16/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
//import openssl
import StoreKit



class ReceiptValidator {

    struct ParsedReceipt {
        let bundleIdentifier: String?
        let bundleIdData: NSData?
        let appVersion: String?
        let opaqueValue: NSData?
        let sha1Hash: NSData?
        let inAppPurchaseReceipts: [ParsedInAppPurchaseReceipt]?
        let originalAppVersion: String?
        let receiptCreationDate: Date?
        let expirationDate: Date?
    }

    struct ParsedInAppPurchaseReceipt {
        let quantity: Int?
        let productIdentifier: String?
        let transactionIdentifier: String?
        let originalTransactionIdentifier: String?
        let purchaseDate: Date?
        let originalPurchaseDate: Date?
        let subscriptionExpirationDate: Date?
        let cancellationDate: Date?
        let webOrderLineItemId: Int?
    }

    func decodeASN1Integer(startOfInt intPointer: inout UnsafePointer<UInt8>?, length: Int) -> Int? {
        // These will be set by ASN1_get_object
        var type = Int32(0)
        var xclass = Int32(0)
        var intLength = 0

        ASN1_get_object(&intPointer, &intLength, &type, &xclass, length)

        guard type == V_ASN1_INTEGER else {
            return nil
        }

        let integer = d2i_ASN1_INTEGER(nil, &intPointer, intLength)
        let result = ASN1_INTEGER_get(integer)
        ASN1_INTEGER_free(integer)

        return result
    }

    private func decodeASN1String(startOfString stringPointer: inout UnsafePointer<UInt8>?, length: Int) -> String? {
        // These will be set by ASN1_get_object
        var type = Int32(0)
        var xclass = Int32(0)
        var stringLength = 0

        ASN1_get_object(&stringPointer, &stringLength, &type, &xclass, length)

        if type == V_ASN1_UTF8STRING {
            let mutableStringPointer = UnsafeMutableRawPointer(mutating: stringPointer!)
            return String(bytesNoCopy: mutableStringPointer, length: stringLength, encoding: String.Encoding.utf8, freeWhenDone: false)
        }

        if type == V_ASN1_IA5STRING {
            let mutableStringPointer = UnsafeMutableRawPointer(mutating: stringPointer!)
            return String(bytesNoCopy: mutableStringPointer, length: stringLength, encoding: String.Encoding.ascii, freeWhenDone: false)
        }

        return nil
    }

    private func decodeASN1Date(startOfDate datePointer: inout UnsafePointer<UInt8>?, length: Int) -> Date? {
        // Date formatter code from https://www.objc.io/issues/17-security/receipt-validation/#parsing-the-receipt
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let dateString = decodeASN1String(startOfString: &datePointer, length:length) {
            return dateFormatter.date(from: dateString)
        }

        return nil
    }

    func parseInAppPurchaseReceipt(currentInAppPurchaseASN1PayloadLocation: inout UnsafePointer<UInt8>?, payloadLength: Int) throws -> ParsedInAppPurchaseReceipt {
        var quantity: Int?
        var productIdentifier: String?
        var transactionIdentifier: String?
        var originalTransactionIdentifier: String?
        var purchaseDate: Date?
        var originalPurchaseDate: Date?
        var subscriptionExpirationDate: Date?
        var cancellationDate: Date?
        var webOrderLineItemId: Int?

        // Find the end of the in-app purchase receipt payload
        let endOfPayload = currentInAppPurchaseASN1PayloadLocation!.advanced(by: payloadLength)
        var type = Int32(0)
        var xclass = Int32(0)
        var length = 0

        ASN1_get_object(&currentInAppPurchaseASN1PayloadLocation, &length, &type, &xclass, payloadLength)

        // Payload must be an ASN1 Set
        guard type == V_ASN1_SET else {
            throw SCError(reason:"malformed in app receipt")
        }

        // Decode Payload
        // Step through payload (ASN1 Set) and parse each ASN1 Sequence within (ASN1 Sets contain one or more ASN1 Sequences)
        while currentInAppPurchaseASN1PayloadLocation! < endOfPayload {

            // Get next ASN1 Sequence
            ASN1_get_object(&currentInAppPurchaseASN1PayloadLocation, &length, &type, &xclass, currentInAppPurchaseASN1PayloadLocation!.distance(to: endOfPayload))

            // ASN1 Object type must be an ASN1 Sequence
            guard type == V_ASN1_SEQUENCE else {
                throw SCError(reason:"malformed in app receipt")
            }

            // Attribute type of ASN1 Sequence must be an Integer
            guard let attributeType = decodeASN1Integer(startOfInt: &currentInAppPurchaseASN1PayloadLocation, length: currentInAppPurchaseASN1PayloadLocation!.distance(to: endOfPayload)) else {
                throw SCError(reason:"malformed in app receipt")
            }

            // Attribute version of ASN1 Sequence must be an Integer
            guard decodeASN1Integer(startOfInt: &currentInAppPurchaseASN1PayloadLocation, length: currentInAppPurchaseASN1PayloadLocation!.distance(to: endOfPayload)) != nil else {
                throw SCError(reason:"malformed in app receipt")
            }

            // Get ASN1 Sequence value
            ASN1_get_object(&currentInAppPurchaseASN1PayloadLocation, &length, &type, &xclass, currentInAppPurchaseASN1PayloadLocation!.distance(to: endOfPayload))

            // ASN1 Sequence value must be an ASN1 Octet String
            guard type == V_ASN1_OCTET_STRING else {
                throw SCError(reason:"malformed in app receipt")
            }

            // Decode attributes
                switch attributeType {
                case 1701:
                    var startOfQuantity = currentInAppPurchaseASN1PayloadLocation
                    quantity = decodeASN1Integer(startOfInt: &startOfQuantity , length: length)
                case 1702:
                    var startOfProductIdentifier = currentInAppPurchaseASN1PayloadLocation
                    productIdentifier = decodeASN1String(startOfString: &startOfProductIdentifier, length: length)
                case 1703:
                    var startOfTransactionIdentifier = currentInAppPurchaseASN1PayloadLocation
                    transactionIdentifier = decodeASN1String(startOfString: &startOfTransactionIdentifier, length: length)
                case 1705:
                    var startOfOriginalTransactionIdentifier = currentInAppPurchaseASN1PayloadLocation
                    originalTransactionIdentifier = decodeASN1String(startOfString: &startOfOriginalTransactionIdentifier, length: length)
                case 1704:
                    var startOfPurchaseDate = currentInAppPurchaseASN1PayloadLocation
                    purchaseDate = decodeASN1Date(startOfDate: &startOfPurchaseDate, length: length)
                case 1706:
                    var startOfOriginalPurchaseDate = currentInAppPurchaseASN1PayloadLocation
                    originalPurchaseDate = decodeASN1Date(startOfDate: &startOfOriginalPurchaseDate, length: length)
                case 1708:
                    var startOfSubscriptionExpirationDate = currentInAppPurchaseASN1PayloadLocation
                    subscriptionExpirationDate = decodeASN1Date(startOfDate: &startOfSubscriptionExpirationDate, length: length)
                case 1712:
                    var startOfCancellationDate = currentInAppPurchaseASN1PayloadLocation
                    cancellationDate = decodeASN1Date(startOfDate: &startOfCancellationDate, length: length)
                case 1711:
                    var startOfWebOrderLineItemId = currentInAppPurchaseASN1PayloadLocation
                    webOrderLineItemId = decodeASN1Integer(startOfInt: &startOfWebOrderLineItemId, length: length)
                default:
                    break
                }

                currentInAppPurchaseASN1PayloadLocation = currentInAppPurchaseASN1PayloadLocation!.advanced(by: length)

        }
        return ParsedInAppPurchaseReceipt(quantity: quantity,
                                          productIdentifier: productIdentifier,
                                          transactionIdentifier: transactionIdentifier,
                                          originalTransactionIdentifier: originalTransactionIdentifier,
                                          purchaseDate: purchaseDate,
                                          originalPurchaseDate: originalPurchaseDate,
                                          subscriptionExpirationDate: subscriptionExpirationDate,
                                          cancellationDate: cancellationDate,
                                          webOrderLineItemId: webOrderLineItemId)
    }

    func getReceipt() throws -> Data {
         guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            throw SCError(reason: "no app store receipt")
        }
         return try Data(contentsOf: receiptUrl)
     }


    func validate(receipt: Data, transaction: SKPaymentTransaction) throws -> Data {

        print("$$$$$ VALIDATE RESEIPT $$$$$$$$$$$$$$")

        // Load the receipt file
         guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            throw SCError(reason: "no app store receipt")
        }
        // vaidate that the receipt passed in is the same at the one in the bundle. Redundant for added security
        let receipt2 = try Data(contentsOf: receiptUrl)
        guard receipt == receipt2 else {
            throw SCError(reason: "invalid receipt param")
        }

        //var receipt = receipt
        //receipt[11] = 0x99

        // Create a memory buffer to extract the PKCS #7 container
        let receiptBIO = BIO_new(BIO_s_mem())
        BIO_write(receiptBIO, receipt.toUnsafePointerBytes, Int32(receipt.count))
        guard let receiptPKCS7:UnsafeMutablePointer<PKCS7> = d2i_PKCS7_bio(receiptBIO, nil) else {
            throw SCError(reason: "cannot create PKCS7")
        }

        // Check that the container has a signature
        guard OBJ_obj2nid(receiptPKCS7.pointee.type) == NID_pkcs7_signed else {
            throw SCError(reason: "receipt not signed")
        }

        guard let appleRootURL = Bundle.main.url(forResource: "AppleIncRootCertificate", withExtension: "cer") else {
            throw SCError(reason: "No root certificate")
        }
        let appleRootData = try Data(contentsOf: appleRootURL)
        let appleRootBIO = BIO_new(BIO_s_mem())
        BIO_write(appleRootBIO, appleRootData.toUnsafePointerBytes, Int32(appleRootData.count))
        let appleRootX509 = d2i_X509_bio(appleRootBIO, nil)

        // Create a certificate store
        let store = X509_STORE_new();
        X509_STORE_add_cert(store, appleRootX509);

        // Be sure to load the digests before the verification
        //////////////////////////OpenSSL_add_all_digests();

        // Check the signature
        let result = PKCS7_verify(receiptPKCS7, nil, store, nil, nil, 0)

        print("$$$$$ VALIDATE RESULT $$$$$$$$$$$$$$")
        print(result)
        print("$$$$$$$$$$$$$$")
        guard result == 1 else {
            throw SCError(reason: "invalid receipt signature \(result)")
        }


        // Must have data to work with
        guard let contents = receiptPKCS7.pointee.d.sign.pointee.contents, let octets = contents.pointee.d.data else {
           throw SCError(reason:"malformedReceipt")
        }

        // Determine the start and end of the receipt payload
        var currentASN1PayloadLocation = UnsafePointer(octets.pointee.data)
        let endOfPayload = currentASN1PayloadLocation!.advanced(by: Int(octets.pointee.length))

        var type = Int32(0)
        var xclass = Int32(0)
        var length = 0

        ASN1_get_object(&currentASN1PayloadLocation, &length, &type, &xclass,Int(octets.pointee.length))

        // Payload must be an ASN1 Set
        guard type == V_ASN1_SET else {
            throw SCError(reason:"malformedReceipt")
        }

        print("$$ ANS1 SET $$$$$$$$$$$$$$$$$$$$")


        var bundleIdentifier: String?
        var bundleIdData: NSData?
        var appVersion: String?
        var opaqueValue: NSData?
        var sha1Hash: NSData?
        var inAppPurchaseReceipts = [ParsedInAppPurchaseReceipt]()
        var originalAppVersion: String?
        var receiptCreationDate: Date?
        var expirationDate: Date?

        // Decode Payload
        // Strategy Step 2: Walk through payload (ASN1 Set) and parse each ASN1 Sequence
        // within (ASN1 Sets contain one or more ASN1 Sequences)
        while currentASN1PayloadLocation! < endOfPayload {

            // Get next ASN1 Sequence
            ASN1_get_object(&currentASN1PayloadLocation, &length, &type, &xclass, currentASN1PayloadLocation!.distance(to: endOfPayload))

            // ASN1 Object type must be an ASN1 Sequence
            guard type == V_ASN1_SEQUENCE else {
                throw SCError(reason:"malformedReceipt")
            }

            // Attribute type of ASN1 Sequence must be an Integer
            guard let attributeType = decodeASN1Integer(startOfInt: &currentASN1PayloadLocation, length: currentASN1PayloadLocation!.distance(to: endOfPayload)) else {
                throw SCError(reason:"malformedReceipt")
            }

            // Attribute version of ASN1 Sequence must be an Integer
            guard decodeASN1Integer(startOfInt: &currentASN1PayloadLocation, length: currentASN1PayloadLocation!.distance(to: endOfPayload)) != nil else {
                throw SCError(reason:"malformedReceipt")
            }

            // Get ASN1 Sequence value
            ASN1_get_object(&currentASN1PayloadLocation, &length, &type, &xclass, currentASN1PayloadLocation!.distance(to: endOfPayload))

            // ASN1 Sequence value must be an ASN1 Octet String
            guard type == V_ASN1_OCTET_STRING else {
                throw SCError(reason:"malformedReceipt")
            }



            // Strategy Step 3: Decode attributes
                switch attributeType {
                case 2:
                    var startOfBundleId = currentASN1PayloadLocation
                    bundleIdData = NSData(bytes: startOfBundleId, length: length)
                    bundleIdentifier = decodeASN1String(startOfString: &startOfBundleId, length: length)
                case 3:
                    var startOfAppVersion = currentASN1PayloadLocation
                    appVersion = decodeASN1String(startOfString: &startOfAppVersion, length: length)
                case 4:
                    let startOfOpaqueValue = currentASN1PayloadLocation
                    opaqueValue = NSData(bytes: startOfOpaqueValue, length: length)
                case 5:
                    let startOfSha1Hash = currentASN1PayloadLocation
                    sha1Hash = NSData(bytes: startOfSha1Hash, length: length)
                case 17:
                    var startOfInAppPurchaseReceipt = currentASN1PayloadLocation
                    let iapReceipt = try parseInAppPurchaseReceipt(currentInAppPurchaseASN1PayloadLocation: &startOfInAppPurchaseReceipt, payloadLength: length)
                    inAppPurchaseReceipts.append(iapReceipt)
                case 12:
                    var startOfReceiptCreationDate = currentASN1PayloadLocation
                    receiptCreationDate = decodeASN1Date(startOfDate: &startOfReceiptCreationDate, length: length)
                case 19:
                    var startOfOriginalAppVersion = currentASN1PayloadLocation
                    originalAppVersion = decodeASN1String(startOfString: &startOfOriginalAppVersion, length: length)
                case 21:
                    var startOfExpirationDate = currentASN1PayloadLocation
                    expirationDate = decodeASN1Date(startOfDate: &startOfExpirationDate, length: length)
                default:
                    break
                }

                currentASN1PayloadLocation = currentASN1PayloadLocation?.advanced(by: length)
        }

        print("$$$INAPP$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
        print(bundleIdentifier ?? "")
        print(inAppPurchaseReceipts)
        print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
        for inAppRec in inAppPurchaseReceipts {
            if inAppRec.productIdentifier == transaction.payment.productIdentifier && inAppRec.transactionIdentifier == transaction.transactionIdentifier {
                return receipt.sha256
            }
        }
        throw SCError(reason: "Purcase validation error")

    }




}
