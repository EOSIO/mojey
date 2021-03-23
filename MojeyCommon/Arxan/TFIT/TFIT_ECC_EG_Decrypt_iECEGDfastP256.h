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
 * TransformIT: ECC/EG/Decrypt Instance=iECEGDfastP256
 */

#ifndef __TFIT_ECC_EG_Decrypt_iECEGDfastP256_H__
#define __TFIT_ECC_EG_Decrypt_iECEGDfastP256_H__

#include "TFIT.h"
#include "TFIT_ECC_EG_Decrypt_iECEGDfastP256-domain.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "TFIT_ECC_EG_Decrypt_iECEGDfastP256-key.h"

int TFIT_wbecc_eg_get_public_key_iECEGDfastP256(
    const TFIT_key_iECEGDfastP256_t * const key,
    uint8_t * const output,
    unsigned int output_len,
    unsigned int * const bytes_written
);

int TFIT_validate_wb_key_iECEGDfastP256(
    const void * const key
);

#include "wbecc_eg_api_codes.h"
#include "libmontbigint_256_32.h"


typedef struct _TFIT_ctx_iECEGDfastP256 {
    uint32_t ws_idx;
    uint8_t ws[TFIT_OCTETS_FOR_COORDINATE_iECEGDfastP256*4];  /* 4 coordinates */
    const TFIT_key_iECEGDfastP256_t * key;
    TFIT_wbecc_domain_host_iECEGDfastP256_t * domain;
    void *constants;
    void *pmscratch;
        
    TFIT_wbecc_pm_table_iECEGDfastP256_t pmtable;
        
} TFIT_ctx_iECEGDfastP256_t;

//auxiliary data and methods needed for eg
    
typedef struct {
    montbi_int_256_32 a, b;
    montbi_int_256_32* i;
    const montbi_ctx_256_32* parent_ctx;
} TFIT_wbecc_montbi_inplace_ctx_iECEGDfastP256;

int TFIT_init_wbecc_eg_iECEGDfastP256(TFIT_ctx_iECEGDfastP256_t * const ctx,
                                  const TFIT_key_iECEGDfastP256_t * const key);

int TFIT_update_wbecc_eg_iECEGDfastP256(TFIT_ctx_iECEGDfastP256_t * const ctx,
                                    const uint8_t * input,
                                    unsigned int input_len,
                                    uint8_t * const output,
                                    unsigned int output_size,
                                    unsigned int * const bytes_written);

int TFIT_final_wbecc_eg_iECEGDfastP256(TFIT_ctx_iECEGDfastP256_t * const ctx,
                                   uint8_t * const output,
                                   unsigned int output_size,
                                   unsigned int * const bytes_written);

#ifdef __cplusplus
}
#endif


#endif /* __TFIT_ECC_EG_Decrypt_iECEGDfastP256_H__ */
