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

#ifndef __TFIT_ECC_GENERATED_IECDSASFASTP256_H__
#define __TFIT_ECC_GENERATED_IECDSASFASTP256_H__

#include "TFIT_ECC_DSA_Sign_iECDSASfastP256-domain.h"
#include "libmontbigint_256_32.h"

#ifdef __cplusplus
extern "C" {
#endif 

#define TFIT_OCTETS_FOR_COORDINATE_iECDSASfastP256 32
#define TFIT_PENTETS_FOR_KEY_iECDSASfastP256 52
#define TFIT_OCTETS_FOR_KEY_iECDSASfastP256 32
#define TFIT_ORDER_BITS_iECDSASfastP256 256

typedef struct _TFIT_ecc_constants_iECDSASfastP256 TFIT_ecc_constants_iECDSASfastP256;

extern const uint8_t TFIT_instance_uuid_iECDSASfastP256[16];

extern const unsigned char TFIT_ecc_mask_iECDSASfastP256[52];

/**
 * Performs the conversion from our form into Weierstrass
 * or Montgomery affine coordinates.  Note that this method assume that
 * the input point is burdened with the addend for points
 * destined for classical output (rClG).
 */
void TFIT_wbecc_convert_to_classical_affine_weierstrass_iECDSASfastP256(TFIT_wbecc_affine_point_host_iECDSASfastP256_t* T, const TFIT_wbecc_point_host_iECDSASfastP256_t* P, const TFIT_ecc_constants_iECDSASfastP256* constants, const TFIT_wbecc_domain_host_iECDSASfastP256_t*domain);

/**
 * Computes T = 32P for a point P in our form
 */
void TFIT_wbecc_shift5_iECDSASfastP256(TFIT_wbecc_point_host_iECDSASfastP256_t* T, const TFIT_wbecc_point_host_iECDSASfastP256_t* P, const TFIT_ecc_constants_iECDSASfastP256* constants, const TFIT_wbecc_domain_host_iECDSASfastP256_t *domain);

/**
 * Computes a multiplication between whitebox-form
 * keys and various constants required for ECDSA.
 */
int TFIT_wbecc_dsa_parameter_helper_iECDSASfastP256(montbi_int_256_32* k_inv_star_m_inv, montbi_int_256_32* d_star, const uint8_t k[], const uint8_t d[], unsigned int len, const TFIT_wbecc_domain_host_iECDSASfastP256_t* domain);

/**
 * Performs point addition of two points in our form
 */
void TFIT_wbecc_add2_iECDSASfastP256(TFIT_wbecc_point_host_iECDSASfastP256_t* T, const TFIT_wbecc_point_host_iECDSASfastP256_t* P1, const TFIT_wbecc_point_host_iECDSASfastP256_t* P2, const TFIT_ecc_constants_iECDSASfastP256* constants, const TFIT_wbecc_domain_host_iECDSASfastP256_t*domain);

/**
 * This struct receives the output of the process of rendering
 * platform independent versions of the constants required by
 * wbecc into a host-performant representation.
 * Once prepared, the constants may be reused with all subsequent
 * calls to wbecc functions functions.
 */
struct _TFIT_ecc_constants_iECDSASfastP256
{
  montbi_int_256_32 con_0;
  montbi_int_256_32 con_1;
  montbi_int_256_32 con_10;
  montbi_int_256_32 con_11;
  montbi_int_256_32 con_12;
  montbi_int_256_32 con_13;
  montbi_int_256_32 con_14;
  montbi_int_256_32 con_2;
  montbi_int_256_32 con_3;
  montbi_int_256_32 con_4;
  montbi_int_256_32 con_5;
  montbi_int_256_32 con_6;
  montbi_int_256_32 con_7;
  montbi_int_256_32 con_8;
  montbi_int_256_32 con_9;
};

extern size_t TFIT_constants_size_iECDSASfastP256;

/**
 * Prepares a host-specific representation of the constants stored within
 * the wbecc code
 */
int TFIT_wbecc_prepare_constants_iECDSASfastP256(TFIT_ecc_constants_iECDSASfastP256* target, const montbi_ctx_256_32* ctx);

#ifdef __cplusplus
}
#endif 

#endif /* __TFIT_ECC_GENERATED_IECDSASFASTP256_H__ */

