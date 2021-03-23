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

#ifndef __TFIT_ECC_DSA_Sign_iECDSASfastP256_key_H__
#define __TFIT_ECC_DSA_Sign_iECDSASfastP256_key_H__

#include "TFIT_ECC_DSA_Sign_iECDSASfastP256-domain.h"
#include "TFIT_ecc_generated_iECDSASfastP256.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif 

typedef struct _TFIT_key_iECDSASfastP256 {
    uint8_t inst_uuid[16];
    uint8_t d[TFIT_PENTETS_FOR_KEY_iECDSASfastP256];
    uint8_t qx[TFIT_OCTETS_FOR_COORDINATE_iECDSASfastP256];
    uint8_t qy[TFIT_OCTETS_FOR_COORDINATE_iECDSASfastP256];
    TFIT_wbecc_point_host_iECDSASfastP256_t epsilon;
    uint8_t nonce_init[32];
} TFIT_key_iECDSASfastP256_t;

#ifdef __cplusplus
}
#endif 

#endif /*__TFIT_ECC_DSA_Sign_iECDSASfastP256_key_H__*/
