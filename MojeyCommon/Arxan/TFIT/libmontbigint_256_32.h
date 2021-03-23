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

#ifndef __MONT_BIGINT_256_32_H__
#define __MONT_BIGINT_256_32_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "libmontbigint_defs.h"

#define MONTBI_WORD_TYPE_256_32 uint32_t
#define MONTBI_MAX_WORDS_256_32  8
#define MONTBI_WORD_BITS_256_32 32



typedef struct __montbi_int_256_32
{
  MONTBI_WORD_TYPE_256_32 digits[MONTBI_MAX_WORDS_256_32]; 
} montbi_int_256_32;



typedef struct __montbi_ctx_256_32
{
  uint32_t mSize;
  montbi_int_256_32 RSq; 
  montbi_int_256_32 n; 
  montbi_int_256_32 one; 
  montbi_int_256_32 nm2; 
  montbi_int_256_32 inv_exp; 
  MONTBI_WORD_TYPE_256_32 nPrimeZero;
} montbi_ctx_256_32;



#include <stddef.h>



int montbi_is_zero_256_32(const montbi_int_256_32 *val,
  const montbi_ctx_256_32 *ctx);




unsigned int montbi_int_serlen_256_32(void);




unsigned int montbi_ctx_serlen_256_32(const montbi_ctx_256_32 *ctx);




int montbi_int_serialize_256_32(unsigned char *buf, 
  size_t bufSize,
  const montbi_int_256_32 *val,
  const montbi_ctx_256_32 *ctx,
  unsigned int *bytes_written);




int montbi_ctx_serialize_256_32(unsigned char *buf, 
  size_t bufSize,
  const montbi_ctx_256_32 *ctx,
  unsigned int *bytes_written);




int montbi_int_deserialize_256_32(const unsigned char *buf,
  size_t bufSize, 
  int from_std,
  montbi_int_256_32 *val,
  unsigned int *bytes_read);



int montbi_ctx_deserialize_256_32(const unsigned char *buf,
  size_t bufSize,
  montbi_ctx_256_32 *ctx,
  unsigned int *bytes_read);




int montbi_init_256_32(montbi_ctx_256_32 *target, 
  const unsigned char n[], 
  size_t nSize, 
  int nFormat, 
  const unsigned char tots_n[]);



int montbi_augment_256_32(montbi_int_256_32* target, const unsigned char a[], size_t aSize, int aFormat, const montbi_ctx_256_32 *ctx);



int montbi_oversize_augment_256_32(montbi_int_256_32* out, 
  const unsigned char a[], 
  size_t aSize, 
  int aFormat, 
  const montbi_ctx_256_32 *ctx);



void montbi_mult_256_32(montbi_int_256_32* target, const montbi_int_256_32* a, const montbi_int_256_32* b, const montbi_ctx_256_32* ctx);



void montbi_exp_256_32(montbi_int_256_32* target, unsigned int exp, const montbi_int_256_32* base, const montbi_ctx_256_32* ctx);



void montbi_big_exp_256_32(montbi_int_256_32* target, const MONTBI_WORD_TYPE_256_32 exp[], MONTBI_WORD_TYPE_256_32 expLen, const montbi_int_256_32* base, const montbi_ctx_256_32* ctx);




void montbi_inv_256_32(montbi_int_256_32* target, const montbi_int_256_32* value, const montbi_ctx_256_32* ctx);



void montbi_add_256_32(montbi_int_256_32* target, const montbi_int_256_32* a, const montbi_int_256_32* b, const montbi_ctx_256_32* ctx);



void montbi_sub_256_32(montbi_int_256_32* target, const montbi_int_256_32* a, const montbi_int_256_32* b, const montbi_ctx_256_32* ctx);



int montbi_reduce_256_32(int *errOut, unsigned char out[], size_t maxOutSize, int outFormat, const montbi_int_256_32* value, const montbi_ctx_256_32 *ctx);




void montbi_raw_print_be_256_32(const char*name, const MONTBI_WORD_TYPE_256_32* value, unsigned int numWords);
void montbi_debug_print_256_32(const char*name, const montbi_int_256_32* value, const montbi_ctx_256_32 *ctx);
void montbi_debug_print_unreduced_256_32(const char*name, const montbi_int_256_32* value, const montbi_ctx_256_32 *ctx, int outFormat);
void montbi_debug_print_ctx_256_32(const char*name, const montbi_ctx_256_32 *ctx, int outFormat);



void montbiutil_in_place_remainder_256_32(MONTBI_WORD_TYPE_256_32 tgt[], unsigned int tgtSize, const MONTBI_WORD_TYPE_256_32 n[], unsigned int nSize);


#ifdef __cplusplus
}
#endif

#endif
