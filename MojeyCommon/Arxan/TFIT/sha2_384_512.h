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

#ifndef __SHA2_384_512_H__
#define __SHA2_384_512_H__

#ifdef __cplusplus
extern "C"{
#endif

#include <stdint.h>

#define SHA2_MODE_384 0
#define SHA2_MODE_512 1

#define SHA2_512_INPUT_BYTES 128   

#define SHA2_384_HASH_LENGTH_OCTETS 48
#define SHA2_512_HASH_LENGTH_OCTETS 64

typedef struct _sha2_512_ctx
{
  uint8_t buffer[SHA2_512_INPUT_BYTES];
  unsigned int buf_used;

  uint64_t len_in_state_high;
  uint64_t len_in_state_low;
  
  uint64_t state[8];
  
  uint8_t mode;
  
} sha2_512_ctx;

void sha2_512_init(sha2_512_ctx *ctx, uint8_t sha2_mode);
void sha2_512_digest(sha2_512_ctx *ctx, const unsigned char *data, unsigned int inLen);
void sha2_512_finalize(const sha2_512_ctx *ctx, unsigned char *out);

#ifdef __cplusplus
}
#endif

#endif 
