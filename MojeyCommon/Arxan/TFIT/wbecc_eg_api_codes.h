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

#ifndef __WBECC_EG_API_CODES_H__
#define __WBECC_EG_API_CODES_H__

    
    
    
    
    typedef enum _wbecc_eg_status_t {
        WBECC_EG_OBFUSCATED_OXDOUT_INVALID = -7,
        WBECC_EG_CLASSICAL_OXDOUT_INVALID = -6,
        WBECC_EG_OBFUSCATED_OXDIN_INVALID = -5,
        WBECC_EG_CLASSICAL_OXDIN_INVALID = -4,
        WBECC_EG_PMULT_FAILURE = -3,
        WBECC_EG_FST_PREPARE_CONSTANTS_ERROR = -2,
        WBECC_EG_INTERNAL_ARITHMETIC_ERROR = -1,

        WBECC_EG_OK = 0,

        WBECC_EG_NULL_PARAM = 1,
        WBECC_EG_FST_TABLE_KEY_PROVIDED = 5,
        WBECC_EG_COMMON_TABLE_KEY_PROVIDED = 6,
        WBECC_EG_KEY_INCOMPATIBLE_WITH_TBL = 7,
        WBECC_EG_DOMAIN_PARAMS_INCOMPATIBLE_WITH_INSTANCE = 8,
        WBECC_EG_OUTPUT_BUFFER_TOO_SMALL = 9,
        WBECC_EG_EXTRA_DATA_REMAINING_IN_INTERNAL_BUFFER = 10,
        WBECC_EG_GET_EPHEMERAL_DATA_FAILURE = 11,
        WBECC_EG_MALLOC_FAILED = 20
    } wbecc_eg_status_t;

#endif
