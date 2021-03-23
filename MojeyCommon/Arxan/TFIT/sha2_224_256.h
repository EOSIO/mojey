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

#ifndef __SHA2_224_256_H__
#define __SHA2_224_256_H__

#ifdef __cplusplus
extern "C"{
#endif

#include <stdint.h>

#define SHA2_MODE_224 0
#define SHA2_MODE_256 1

#define SHA2_256_INPUT_BYTES 64   

#define SHA2_224_HASH_LENGTH_OCTETS 28
#define SHA2_256_HASH_LENGTH_OCTETS 32


extern uint8_t SHA2_256_EMPTY_HASH[SHA2_256_HASH_LENGTH_OCTETS];

typedef struct _sha2_256_ctx
{
  uint8_t buffer[SHA2_256_INPUT_BYTES];
  unsigned int buf_used;

  uint64_t len_in_state;
  uint32_t state[8];
  
  uint8_t mode;
  
} sha2_256_ctx;

void sha2_256_init(sha2_256_ctx *ctx, uint8_t sha2_mode);
void sha2_256_digest(sha2_256_ctx *ctx, const unsigned char *data, unsigned int inLen);
void sha2_256_finalize(const sha2_256_ctx *ctx, unsigned char *out);

#ifdef __cplusplus
}
#endif

#endif 
