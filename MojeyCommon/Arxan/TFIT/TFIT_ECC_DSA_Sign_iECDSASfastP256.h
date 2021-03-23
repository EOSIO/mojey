/*
 * TransformIT 8.0 (GA) EvalKit
 *
 * Copyright (C) Arxan Technologies Inc. 2017.
 * All rights Reserved.
 *
 *
 * Portions of the information disclosed herein are protected by
 * U.S. Patent No. 6,941,463, U.S. Patent No. 6,957,341, U.S. Patent 7,287,166,
 * U.S. Patent 7,707,433, U.S. Patent 7,757,097, U.S. Patent 7,853,018,
 * U.S. Patent 8,510,571, U.S. Patent 9,262,600, and Patents Pending.
 *
 */

/*
 * TransformIT: ECC/DSA Instance=iECDSASfastP256
 */

#ifndef __TFIT_ECC_DSA_SIGN_iECDSASfastP256_H__
#define __TFIT_ECC_DSA_SIGN_iECDSASfastP256_H__

#include "TFIT.h"

#include "TFIT_ECC_DSA_Sign_iECDSASfastP256-domain.h"
#include "sha1.h"
#include "sha2_224_256.h"
#include "sha2_384_512.h"
#include "wbecc_dsa_api_codes.h"
#include "get_random_data.h"

#ifndef __GNUC__
#ifndef __attribute__
#define __attribute__( A )
#endif /* __attribute__ */
#endif /* __GNUC__ */

#ifdef __cplusplus
extern "C" {
#endif

#include "TFIT_ECC_DSA_Sign_iECDSASfastP256-key.h"

int TFIT_wbecc_dsa_get_public_key_iECDSASfastP256(
    const TFIT_key_iECDSASfastP256_t * const key,
    uint8_t * const output,
    unsigned int output_len,
    unsigned int * const bytes_written
);

int TFIT_validate_wb_key_iECDSASfastP256(
    const void * const key
);

typedef
#ifdef _MSC_VER
__declspec( align( 4 ) )
#endif
struct _TFIT_ctx_iECDSASfastP256 {
    union {
       sha1_context ctx_1;
       sha2_256_ctx ctx_256;
       sha2_512_ctx ctx_512;
    } hash_ctx;
    unsigned int hash_length; // in bytes
    wbecc_digest_mode_t digest_mode;
    const TFIT_key_iECDSASfastP256_t * key;
    TFIT_get_nonce_t get_nonce_data;
    TFIT_wbecc_domain_host_iECDSASfastP256_t * domain;
    void *constants;
} __attribute__((aligned(0x04))) TFIT_ctx_iECDSASfastP256_t;

int TFIT_init_wbecc_dsa_iECDSASfastP256(TFIT_ctx_iECDSASfastP256_t * const ctx,
                                   const TFIT_key_iECDSASfastP256_t * const key,
                                   TFIT_get_nonce_t get_nonce_data,
                                   const wbecc_digest_mode_t digest_mode);

int TFIT_init_wbecc_dsa_deterministic_nonce_iECDSASfastP256(TFIT_ctx_iECDSASfastP256_t * const ctx,
                                                       const TFIT_key_iECDSASfastP256_t * const key,
                                                       const wbecc_digest_mode_t digest_mode);

int TFIT_update_wbecc_dsa_iECDSASfastP256(TFIT_ctx_iECDSASfastP256_t * const ctx,
                                   const uint8_t * const input, 
                                   const unsigned int input_len);

int TFIT_final_sign_wbecc_dsa_iECDSASfastP256(TFIT_ctx_iECDSASfastP256_t * const ctx,
                                         uint8_t * const r,
                                         unsigned int r_size,                 
                                         unsigned int * const r_bytes_written,       
                                         uint8_t * const s,
                                         unsigned int s_size,
                                         unsigned int * const s_bytes_written);

int TFIT_sign_digest_wbecc_dsa_iECDSASfastP256(TFIT_ctx_iECDSASfastP256_t * const ctx,
                                         const uint8_t * const digest,
                                         const unsigned int digest_len,
                                         uint8_t * const r,
                                         unsigned int r_size,                 
                                         unsigned int * const r_bytes_written,       
                                         uint8_t * const s,
                                         unsigned int s_size,
                                         unsigned int * const s_bytes_written);


#ifdef __cplusplus
}
#endif


#endif /* __TFIT_ECC_DSA_SIGN_iECDSASfastP256_H__ */
