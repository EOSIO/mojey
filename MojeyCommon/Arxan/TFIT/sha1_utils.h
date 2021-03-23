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

#ifndef __SHA1_UTILS_H__
#define __SHA1_UTILS_H__

#include <stdint.h>
#include <string.h>

#if defined(__sparc__) || defined(__arm__) || defined(__arm64__) || defined(_M_ARM_FP)

  #define __ALIGNED_MEMACCESS   1

  #define MEMCPY_DST_SRC(d, s, slen) \
  { \
    size_t ___temp; \
    for(___temp=0; ___temp < (slen); ___temp++){ \
      ((uint8_t *)(d))[___temp] = ((uint8_t *)(s))[___temp]; \
    } \
  }

  #define COPY_DST_SRC(a,b,bLen) MEMCPY_DST_SRC((a), (b), (bLen) * sizeof((b)[0]))

#else

  #define COPY_DST_SRC(a,b,bLen) \
  { \
    unsigned int ___temp; \
    for(___temp = 0;___temp < (bLen);___temp++){ \
      (a)[___temp] = (b)[___temp]; \
    } \
  }

#endif

#if defined(__BYTE_ORDER)
  #if __BYTE_ORDER == __LITTLE_ENDIAN
    

  #elif __BYTE_ORDER == __BIG_ENDIAN
    

  #elif __BYTE_ORDER == __PDP_ENDIAN
    #error PDP/ARM endianness not supported.
  #else
    #error Unknown endianness.
  #endif
#else 

  

  #if defined(__LITTLE_ENDIAN)
    #define __BYTE_ORDER __LITTLE_ENDIAN
  #elif defined(__BIG_ENDIAN)
    #define __BYTE_ORDER __BIG_ENDIAN
  #elif defined(__PDP_ENDIAN)
    #error PDP/ARM endianness not supported.
  #else 

    #define __LITTLE_ENDIAN 1234
    #define __BIG_ENDIAN    4321
    #define __PDP_ENDIAN    3412
    #if defined(__powerpc__) || defined(__PPC__) || defined(__ppc) \
        || defined (_M_PPC) || defined(__sparc__)
      #define __BYTE_ORDER __BIG_ENDIAN
    #elif defined(_M_IX86) || defined(_M_X64) || defined(_M_ARM_FP) \
        || defined(__i386__) || defined(__x86_64__) \
        || defined(__arm__)  || defined(__arm64__) || defined(__aarch64__)
      #define __BYTE_ORDER __LITTLE_ENDIAN
    #else
      #error Unable to determine endianness.
    #endif
  #endif
#endif

#if __BYTE_ORDER == __BIG_ENDIAN

  #define BIG_ENDIAN_BITS_TO_UINT32(a) (a)

  #define UINT32_TO_BIG_ENDIAN_BITS(a) (a)

  #define ROTATE_LEFT(a, b) ((((uint32_t)(a)) << (b)) | (((uint32_t)(a)) >> (sizeof(uint32_t)*8-(b))))

#elif __BYTE_ORDER == __LITTLE_ENDIAN

  #define BIG_ENDIAN_BITS_TO_UINT32(a) \
  ( \
    ((a) >> 24) \
    | (((a) & 0x00ff0000) >> 8) \
    | (((a) & 0x0000ff00) << 8) \
    | (((a) & 0x000000ff) << 24)\
  )

  #define UINT32_TO_BIG_ENDIAN_BITS(a) \
  ( \
    ((a) >> 24) \
    | (((a) & 0x00ff0000) >> 8) \
    | (((a) & 0x0000ff00) << 8) \
    | (((a) & 0x000000ff) << 24)\
  )

  #define ROTATE_LEFT(a, b) ((((uint32_t)(a)) << (b)) | (((uint32_t)(a)) >> (sizeof(uint32_t)*8-(b))))

#else
  #error Unable to determine endianness.
#endif

#endif 
