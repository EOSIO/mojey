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

#ifndef __WBECC_DSA_API_CODES_H__
#define __WBECC_DSA_API_CODES_H__

    
    
    
    
    typedef enum _wbecc_dsa_status_t {
        WBECC_DSA_PMULT_FAILURE = -14,
        WBECC_DSA_PROJECTIFY_FAILURE = -13,
        WBECC_DSA_RESULT_INPUT_MISMATCH = -12,
        WBECC_DSA_SUB_FAILURE = -11,
        WBECC_DSA_OVERSIZE_AUGMENT_FAILED = -10,
        WBECC_DSA_FAILED_TO_PREP_FROM_K_AND_D = -9,
        WBECC_DSA_MONTBI_REDUCE_ERROR = -8,
        WBECC_DSA_FST_PREPARE_CONSTANTS_ERROR = -7,
        WBECC_DSA_REDUCE_FAILURE = -6,
        WBECC_DSA_INVERT_FAILURE = -5,
        WBECC_DSA_MULT_FAILURE = -4,
        WBECC_DSA_ADD_FAILURE = -3,
        WBECC_DSA_AFFINIFY_FAILURE = -2,
        WBECC_DSA_SHA_FINAL_ERROR = -1,

        WBECC_DSA_OK = 0,

        WBECC_DSA_GET_NONCE_DATA_FAILURE = 1,
        WBECC_DSA_R_OUTPUT_BUFFER_TOO_SMALL = 2,
        WBECC_DSA_S_OUTPUT_BUFFER_TOO_SMALL = 3,
        WBECC_DSA_KEY_INSTANCE_ID_MISMATCH = 4,
        WBECC_DSA_DOMAIN_INSTANCE_ID_MISMATCH = 5,
        WBECC_DSA_MALLOC_FAILED = 6,
        WBECC_DSA_WRONG_KEY_TYPE = 13,
        WBECC_DSA_NULL_PARAM = 14,
        WBECC_DSA_R_INPUT_WRONG_SIZE = 23,
        WBECC_DSA_S_INPUT_WRONG_SIZE = 24,
        WBECC_DSA_Q_INPUT_WRONG_SIZE = 25,
        WBECC_DSA_RESULT_INPUT_WRONG_SIZE = 26,
        WBECC_DSA_SIG_VERIFY_FAILURE = 29,
        WBECC_DSA_INVALID_DIGEST_LENGTH = 34,
        WBECC_DSA_DIGEST_ALREADY_EXISTS = 35,
        WBECC_DSA_INVALID_DIGEST_MODE = 36
    } wbecc_dsa_status_t;
    
    typedef enum {
        WBECC_SHA1 = 0,     
        WBECC_SHA2_224 = 1, 
        WBECC_SHA2_256 = 2, 
        WBECC_SHA2_384 = 3,
        WBECC_SHA2_512 = 4
    } wbecc_digest_mode_t;

#endif
