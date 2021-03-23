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

#ifndef __TFIT_ECC_DSA_Sign_iECDSASfastP256_domain_H__
#define __TFIT_ECC_DSA_Sign_iECDSASfastP256_domain_H__

#ifdef __cplusplus
extern "C" {
#endif 

#include <stdint.h>
#include <stddef.h>
#include "TFIT.h" 

typedef struct _TFIT_wbecc_sdp_header_common_iECDSASfastP256
{
  uint8_t magic[4];
  uint8_t version[4];
} TFIT_wbecc_sdp_header_common_iECDSASfastP256_t;

typedef struct _TFIT_wbecc_sdp_header_v1_iECDSASfastP256
{
  TFIT_wbecc_sdp_header_common_iECDSASfastP256_t common;
  uint8_t total_size[4];
  uint8_t mod_size[4];
  uint8_t montbi_ctx_ver[4];
  uint8_t montbi_ctx_size[4];
  uint8_t reserved[8];
} TFIT_wbecc_sdp_header_v1_iECDSASfastP256_t;

#include "libmontbigint_256_32.h"

/**
 * Host-dependent working forms
 */
typedef struct _TFIT_wbecc_affine_point_host_iECDSASfastP256
{
  montbi_int_256_32 x;
  montbi_int_256_32 y;
} TFIT_wbecc_affine_point_host_iECDSASfastP256_t;

typedef struct _TFIT_wbecc_point_host_iECDSASfastP256
{
  montbi_int_256_32 xn;
  montbi_int_256_32 xd;
  montbi_int_256_32 yn;
  montbi_int_256_32 yd;
} TFIT_wbecc_point_host_iECDSASfastP256_t;

typedef struct _TFIT_wbecc_domain_host_iECDSASfastP256
{
  /* Prime field modulus */
  montbi_ctx_256_32 ctx;

  /* Curve order */
  montbi_ctx_256_32 order_ctx;

  /* Curve params */
  montbi_int_256_32 d;
  montbi_int_256_32 tm2;

  /* Isomorphism Params */
  montbi_int_256_32 kSq;
  montbi_int_256_32 kCu;
  montbi_int_256_32 kSqInv;
  montbi_int_256_32 kCuInv;
  montbi_int_256_32 kSqInvTwelfthb2;

  /* rOutG */
  TFIT_wbecc_point_host_iECDSASfastP256_t rOutG;

  /* transG */
  TFIT_wbecc_point_host_iECDSASfastP256_t transG;

  /* transO */
  TFIT_wbecc_point_host_iECDSASfastP256_t transO;

  /* rnd_{T}G[i] */
  TFIT_wbecc_point_host_iECDSASfastP256_t rndTG[32];

  /* pre_{O}[i] */
  TFIT_wbecc_point_host_iECDSASfastP256_t preO[32];

  /* c_{T,cl}[i] */
  TFIT_wbecc_point_host_iECDSASfastP256_t cTCl[32];


  /* pre_{G}[i] */
  TFIT_wbecc_point_host_iECDSASfastP256_t preG[32];

  /* Paramters for ECDSA out-path */
  montbi_int_256_32 starInvM;
  montbi_int_256_32 starInvSqM;

} TFIT_wbecc_domain_host_iECDSASfastP256_t;


/**
 * Utility function for parsing a serialized-format set of domain parameters
 * into a host-format set of domain parameters 
 */
int TFIT_wbecc_parse_domain_params_iECDSASfastP256(TFIT_wbecc_domain_host_iECDSASfastP256_t* target, const void * serialized_data, unsigned int serialized_data_len);


#ifdef __cplusplus
}
#endif 

#endif /*__TFIT_ECC_DSA_Sign_iECDSASfastP256_domain_H__*/
