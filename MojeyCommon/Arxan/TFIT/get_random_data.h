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

#ifndef __GET_RANDOM_DATA_H__
#define __GET_RANDOM_DATA_H__

#ifdef __cplusplus
extern "C" {
#endif

typedef int (*TFIT_get_random_data_t) (const unsigned int, unsigned char * const);

#define TFIT_get_nonce_t TFIT_get_random_data_t
#define TFIT_get_ephemeral_t TFIT_get_random_data_t

#ifdef __cplusplus
}
#endif

#endif 
