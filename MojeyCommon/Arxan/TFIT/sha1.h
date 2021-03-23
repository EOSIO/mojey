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

#ifndef __SHA_1__
#define __SHA_1__

#ifdef __cplusplus
extern "C"{
#endif

#include "sha1_utils.h"

#define SHA1_INPUT_BYTES 64        

#define SHA1_HASH_LENGTH_OCTETS 20


extern uint8_t SHA1_EMPTY_HASH[SHA1_HASH_LENGTH_OCTETS];

typedef struct _sha1_context
{
  uint8_t buffer[SHA1_INPUT_BYTES];
  unsigned int buf_used;

  uint64_t len_in_state;
  uint32_t state[5];
  
} sha1_context;

void sha1_initialize(sha1_context *ctx);
void sha1_digest(sha1_context *ctx, const unsigned char *data, unsigned int inLen);
void sha1_finalize(const sha1_context *ctx, unsigned char *result);

void sha1(const uint8_t *data, const unsigned int dLen, uint8_t *result);

#ifdef __cplusplus
}
#endif

#endif 
