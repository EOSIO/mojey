//
//
//  Created by Todd Bowden on 7/11/18.
// Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//
#ifndef LIBRECOVER
#define LIBRECOVER

#include <stdbool.h>
#include <stddef.h>
#include <openssl/ecdsa.h>
#include <openssl/bn.h>
#include <openssl/obj_mac.h>
#include <openssl/asn1.h>
#include <openssl/pkcs7.h>
#include <openssl/x509_vfy.h>
#include <openssl/evp.h>

#endif


int ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check);


