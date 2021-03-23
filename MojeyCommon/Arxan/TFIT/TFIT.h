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
 * TransformIT: Common Declarations
 */

#ifndef __TFIT_H__
#define __TFIT_H__

#define TFIT_VERSION 8.0
#define TFIT_KIT_ID  evalkit_8_0
#define TFIT_KIT_ID_evalkit_8_0 1


/*
 * AES:
 */

#define AES_BLOCK_SIZE 16

// typedef wbaes_status_t:
#define TFIT_WBAES_OK                                          WBAES_OK                                          // 0 
#define TFIT_WBAES_MISMATCH_ECB_INPUT_FORM                     WBAES_MISMATCH_ECB_INPUT_FORM                     // 1 
#define TFIT_WBAES_MISMATCH_ECB_OUTPUT_FORM                    WBAES_MISMATCH_ECB_OUTPUT_FORM                    // 2 
#define TFIT_WBAES_MISMATCH_ECB_DIRECTION                      WBAES_MISMATCH_ECB_DIRECTION                      // 3 
#define TFIT_WBAES_MISMATCH_ECB_KEY                            WBAES_MISMATCH_ECB_KEY                            // 4 
#define TFIT_WBAES_MISMATCH_WRAP_INPUT_FORM                    WBAES_MISMATCH_WRAP_INPUT_FORM                    // 5 
#define TFIT_WBAES_MISMATCH_WRAP_OUTPUT_FORM                   WBAES_MISMATCH_WRAP_OUTPUT_FORM                   // 6 
#define TFIT_WBAES_MISMATCH_WRAP_DIRECTION                     WBAES_MISMATCH_WRAP_DIRECTION                     // 7 
#define TFIT_WBAES_MISMATCH_WRAP_KEY                           WBAES_MISMATCH_WRAP_KEY                           // 8 
#define TFIT_WBAES_MISMATCH_CMLA_INPUT_FORM                    WBAES_MISMATCH_CMLA_INPUT_FORM                    // 9 
#define TFIT_WBAES_MISMATCH_CMLA_OUTPUT_FORM                   WBAES_MISMATCH_CMLA_OUTPUT_FORM                   // 10
#define TFIT_WBAES_MISMATCH_CMLA_DIRECTION                     WBAES_MISMATCH_CMLA_DIRECTION                     // 11
#define TFIT_WBAES_MISMATCH_CMLA_KEY                           WBAES_MISMATCH_CMLA_KEY                           // 12
#define TFIT_WBAES_UNALIGNED                                   WBAES_UNALIGNED                                   // 13
#define TFIT_WBAES_OVERFLOW                                    WBAES_OVERFLOW                                    // 14   
#define TFIT_WBAES_INTERNAL_ERROR                              WBAES_INTERNAL_ERROR                              // 15
#define TFIT_WBAES_FUNC_ERROR                                  WBAES_FUNC_ERROR                                  // 16
#define TFIT_WBAES_NULL_ARG                                    WBAES_NULL_ARG                                    // 17
#define TFIT_WBAES_UPDATING_FINALIZED_CTX                      WBAES_UPDATING_FINALIZED_CTX                      // 18
#define TFIT_WBAES_MEMORY_ALLOCATION_FAIL                      WBAES_MEMORY_ALLOCATION_FAIL                      // 19
#define TFIT_WBAES_INVALID_MSG_SIZE                            WBAES_INVALID_MSG_SIZE                            // 20
#define TFIT_WBAES_OUTPUT_BUFFER_TOO_SMALL                     WBAES_OUTPUT_BUFFER_TOO_SMALL                     // 21
#define TFIT_WBAES_INVALID_DIGEST_LEN                          WBAES_INVALID_DIGEST_LEN                          // 22
#define TFIT_WBAES_KEY_BUFFER_TOO_SMALL                        WBAES_KEY_BUFFER_TOO_SMALL                        // 23
#define TFIT_WBAES_KEY_DYNINIT_FAIL                            WBAES_KEY_DYNINIT_FAIL                            // 24
#define TFIT_WBAES_SLICE_UNKNOWN_ERROR                         WBAES_SLICE_UNKNOWN_ERROR                         // 25
#define TFIT_WBAES_SLICE_NULL_ARG                              WBAES_SLICE_NULL_ARG                              // 26
#define TFIT_WBAES_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE WBAES_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE // 27
#define TFIT_WBAES_SLICE_INTERNAL_ERROR                        WBAES_SLICE_INTERNAL_ERROR                        // 28
#define TFIT_WBAES_TAG_NOT_GCM                                 WBAES_TAG_NOT_GCM                                 // 29
#define TFIT_WBAES_INVALID_TAG_LENGTH                          WBAES_INVALID_TAG_LENGTH                          // 30
#define TFIT_WBAES_GCM_NOT_FINALIZED                           WBAES_GCM_NOT_FINALIZED                           // 31
#define TFIT_WBAES_KDF_INVALID_OUTPUT_LENGTH                   WBAES_KDF_INVALID_OUTPUT_LENGTH                   // 33
#define TFIT_WBAES_MODE_INVALID                                WBAES_MODE_INVALID                                // 34
#define TFIT_WBAES_DIRECTION_INVALID                           WBAES_DIRECTION_INVALID                           // 35
#define TFIT_WBAES_MODE_MISMATCH                               WBAES_MODE_MISMATCH                               // 36
#define TFIT_WBAES_CMAC_INCOMPATIBLE_ECB_INSTANCE              WBAES_CMAC_INCOMPATIBLE_ECB_INSTANCE              // 37
#define TFIT_WBAES_CMAC_INCOMPATIBLE_ECB_KEY                   WBAES_CMAC_INCOMPATIBLE_ECB_KEY                   // 38
#define TFIT_WBAES_INVALID_INPUT_OPT                           WBAES_INVALID_INPUT_OPT                           // 39
#define TFIT_WBAES_MSG_NOT_VERIFIED                            WBAES_MSG_NOT_VERIFIED                            // 40


/*
 * CMLA/KDF
 */

// enum wbcmla_status_t:
#define TFIT_WBCMLA_OK                                          WBCMLA_OK                                          // 0 
#define TFIT_WBCMLA_NULL_ARG                                    WBCMLA_NULL_ARG                                    // 1 
#define TFIT_WBCMLA_INVALID_INPUT_LEN                           WBCMLA_INVALID_INPUT_LEN                           // 2 
#define TFIT_WBCMLA_INVALID_OUTPUT_LEN                          WBCMLA_INVALID_OUTPUT_LEN                          // 3 
#define TFIT_WBCMLA_SLICE_UNKNOWN_ERROR                         WBCMLA_SLICE_UNKNOWN_ERROR                         // 4 
#define TFIT_WBCMLA_SLICE_NULL_ARG                              WBCMLA_SLICE_NULL_ARG                              // 5 
#define TFIT_WBCMLA_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE WBCMLA_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE // 6
#define TFIT_WBCMLA_SLICE_INTERNAL_ERROR                        WBCMLA_SLICE_INTERNAL_ERROR                        // 7 
#define TFIT_WBCMLA_SLICE_UNSUPPORTED_WORD_SIZE                 WBCMLA_SLICE_UNSUPPORTED_WORD_SIZE                 // 8 
#define TFIT_WBCMLA_SLICE_INVALID_BYTE_ORDER_IN_WORD            WBCMLA_SLICE_INVALID_BYTE_ORDER_IN_WORD            // 9 
#define TFIT_WBCMLA_SHA_UNKNOWN_ERROR                           WBCMLA_SHA_UNKNOWN_ERROR                           // 10
#define TFIT_WBCMLA_SHA_OUTPUT_ERROR                            WBCMLA_SHA_OUTPUT_ERROR                            // 11
#define TFIT_WBCMLA_BBI_MULTIPLY_ERROR                          WBCMLA_BBI_MULTIPLY_ERROR                          // 12
#define TFIT_WBCMLA_BBI_ADD_ERROR                               WBCMLA_BBI_ADD_ERROR                               // 13
#define TFIT_WBCMLA_BBI_INIT_ERROR                              WBCMLA_BBI_INIT_ERROR                              // 14
#define TFIT_WBCMLA_BBI_F_ERROR                                 WBCMLA_BBI_F_ERROR                                 // 15
#define TFIT_WBCMLA_BBI_F2_ERROR                                WBCMLA_BBI_F2_ERROR                                // 16
#define TFIT_WBCMLA_BBI_REDUCE_ERROR                            WBCMLA_BBI_REDUCE_ERROR                            // 17    


/*
 * DES/3DES
 */

#define TFIT_WBDES_BLOCK_SIZE 8

// enum wbdes_status_t:
#define TFIT_WBDES_OK                                          WBDES_OK                                          // 0
#define TFIT_WBDES_MISMATCH_ECB_INPUT_FORM                     WBDES_MISMATCH_ECB_INPUT_FORM                     // 1
#define TFIT_WBDES_MISMATCH_ECB_OUTPUT_FORM                    WBDES_MISMATCH_ECB_OUTPUT_FORM                    // 2
#define TFIT_WBDES_MISMATCH_ECB_DIRECTION                      WBDES_MISMATCH_ECB_DIRECTION                      // 3
#define TFIT_WBDES_MISMATCH_ECB_KEY                            WBDES_MISMATCH_ECB_KEY                            // 4
#define TFIT_WBDES_UNALIGNED                                   WBDES_UNALIGNED                                   // 5
#define TFIT_WBDES_OVERFLOW                                    WBDES_OVERFLOW                                    // 6
#define TFIT_WBDES_INTERNAL_ERROR                              WBDES_INTERNAL_ERROR                              // 7
#define TFIT_WBDES_FUNC_ERROR                                  WBDES_FUNC_ERROR                                  // 8
#define TFIT_WBDES_NULL_ARG                                    WBDES_NULL_ARG                                    // 9
#define TFIT_WBDES_UPDATING_FINALIZED_CTX                      WBDES_UPDATING_FINALIZED_CTX                      // 10
#define TFIT_WBDES_MEMORY_ALLOCATION_FAIL                      WBDES_MEMORY_ALLOCATION_FAIL                      // 11
#define TFIT_WBDES_INVALID_MSG_SIZE                            WBDES_INVALID_MSG_SIZE                            // 12
#define TFIT_WBDES_OUTPUT_BUFFER_TOO_SMALL                     WBDES_OUTPUT_BUFFER_TOO_SMALL                     // 13
#define TFIT_WBDES_KEY_BUFFER_TOO_SHORT                        WBDES_KEY_BUFFER_TOO_SHORT                        // 14
#define TFIT_WBDES_KEY_DYNINIT_FAIL                            WBDES_KEY_DYNINIT_FAIL                            // 15
#define TFIT_WBDES_SLICE_UNKNOWN_ERROR                         WBDES_SLICE_UNKNOWN_ERROR                         // 16
#define TFIT_WBDES_SLICE_NULL_ARG                              WBDES_SLICE_NULL_ARG                              // 17
#define TFIT_WBDES_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE WBDES_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE // 18
#define TFIT_WBDES_SLICE_INTERNAL_ERROR                        WBDES_SLICE_INTERNAL_ERROR                        // 19
#define TFIT_WBDES_KDF_INVALID_OUTPUT_LENGTH                   WBDES_KDF_INVALID_OUTPUT_LENGTH                   // 20
#define TFIT_WBDES_UNINITIALIZED_CTX 21
#define TFIT_WBDES_DK_INVALID_KEY_LEN 22


/*
 * ECC:
 *
 * The following routines, common to all ECC-variants, utilize these return-codes:
 *
 *    TFIT_wbecc_<variant>_get_public_key_<Instance>
 *    TFIT_prepare_dynamic_key_<Instance> (non-Fast instances only)
 */

// enum wbecc_common_status_t:
#define TFIT_WBECC_COMMON_INTERNAL_ARITHMETIC_ERROR WBECC_COMMON_INTERNAL_ARITHMETIC_ERROR  // -1 (still used in std-mode ecc)
#define TFIT_WBECC_COMMON_OK 0
#define TFIT_WBECC_COMMON_NULL_PARAM 41
#define TFIT_WBECC_COMMON_OUTPUT_BUFFER_TOO_SMALL 42
#define TFIT_WBECC_COMMON_VALIDATE_FAILURE 47

//note 6.6 release added the factor of 40 to distinguish from variant specific return codes
//note 7.0 release removed codes 43-46 and -1 and added code 47

/*
 *    TFIT_prepare_dynamic_key_<Instance> (Fast instances only)
 */

#define TFIT_WBECC_FAST_PREPARE_KEY_SUCCESS          WBECC_FAST_PREPARE_KEY_SUCCESS         // 0
#define TFIT_WBECC_FAST_PREPARE_KEY_INPUT_TOO_SHORT  WBECC_FAST_PREPARE_KEY_INPUT_TOO_SHORT // 1
#define TFIT_WBECC_FAST_PREPARE_KEY_INPUT_TOO_LONG   WBECC_FAST_PREPARE_KEY_INPUT_TOO_LONG  // 2
#define TFIT_WBECC_FAST_PREPARE_KEY_ILLEGAL_ARG      WBECC_FAST_PREPARE_KEY_ILLEGAL_ARG     // 3
//Return codes 4 and 5 were internal codes moved to -1,-2 respectively in 6.6 release.

// Internal return-codes:
#define TFIT_WBECC_FAST_PREPARE_KEY_REDUCE_FAILED    WBECC_FAST_PREPARE_KEY_REDUCE_FAILED   // -1
#define TFIT_WBECC_FAST_PREPARE_KEY_PMULT_FAILED     WBECC_FAST_PREPARE_KEY_PMULT_FAILED    // -2

/*
 * The following internal ECC codes are common to all variants.
 * These could occur on domain parsing (deserialization) errors
 */

#define TFIT_WBECC_DOMAIN_OK                                0
#define TFIT_WBECC_DOMAIN_NOT_SDP                         -21
#define TFIT_WBECC_DOMAIN_UNSUPPORTED_SDP                 -22
#define TFIT_WBECC_DOMAIN_BAD_SDP_LEN                     -23
#define TFIT_WBECC_DOMAIN_INCOMPATIBLE_SDP_MOD_SIZE       -24
#define TFIT_WBECC_DOMAIN_INTERNAL_ERROR                  -25
#define TFIT_WBECC_DOMAIN_UNKNOWN_MONTBI_CTX_VERSION      -26
#define TFIT_WBECC_DOMAIN_BAD_MONTBI_CTX_SERLEN           -27
#define TFIT_WBECC_DOMAIN_FAILED_DESERIALIZING_MONTBI_CTX -28
#define TFIT_WBECC_DOMAIN_MONTBI_CTX_DESERIALIZE_BAD_SIZE -29
#define TFIT_WBECC_DOMAIN_POINT_NOT_ON_CURVE              -30

/*
 * ECC/DH:
 */

// enum ecc_dh_mode_t:
#define TFIT_WBECC_DH_FULL_UNIFIED_MODEL                WBECC_DH_FULL_UNIFIED_MODEL                // 0
#define TFIT_WBECC_DH_EPHEMERAL_UNIFIED_MODEL           WBECC_DH_EPHEMERAL_UNIFIED_MODEL           // 1
#define TFIT_WBECC_DH_ONE_PASS_UNIFIED_MODEL_INITIATOR  WBECC_DH_ONE_PASS_UNIFIED_MODEL_INITIATOR  // 2
#define TFIT_WBECC_DH_ONE_PASS_UNIFIED_MODEL_RESPONDER  WBECC_DH_ONE_PASS_UNIFIED_MODEL_RESPONDER  // 3
#define TFIT_WBECC_DH_ONE_PASS_DIFFIE_HELLMAN_INITIATOR WBECC_DH_ONE_PASS_DIFFIE_HELLMAN_INITIATOR // 4
#define TFIT_WBECC_DH_ONE_PASS_DIFFIE_HELLMAN_RESPONDER WBECC_DH_ONE_PASS_DIFFIE_HELLMAN_RESPONDER // 5
#define TFIT_WBECC_DH_STATIC_UNIFIED_MODEL              WBECC_DH_STATIC_UNIFIED_MODEL              // 6

// enum _wbecc_dh_status_t:
#define TFIT_WBECC_DH_OK                                       WBECC_DH_OK                                       // 0
#define TFIT_WBECC_DH_NULL_PARAM                               WBECC_DH_NULL_PARAM                               // 1
#define TFIT_WBECC_DH_FST_BUT_STD_KEY_PROVIDED                 WBECC_DH_FST_BUT_STD_KEY_PROVIDED                 // 5
#define TFIT_WBECC_DH_DO_NOT_HAVE_STATIC_KEY                   WBECC_DH_DO_NOT_HAVE_STATIC_KEY                   // 6
#define TFIT_WBECC_DH_DO_NOT_HAVE_EPHEMERAL_KEY                WBECC_DH_DO_NOT_HAVE_EPHEMERAL_KEY                // 7
#define TFIT_WBECC_DH_OUTPUT_BUFFER_TOO_SMALL                  WBECC_DH_OUTPUT_BUFFER_TOO_SMALL                  // 8
#define TFIT_WBECC_DH_GET_EPHEMERAL_DATA_FAILURE               WBECC_DH_GET_EPHEMERAL_DATA_FAILURE               // 9
#define TFIT_WBECC_DH_PARSE_AFFINE_POINT_FAILURE               WBECC_DH_PARSE_AFFINE_POINT_FAILURE               // 10
#define TFIT_WBECC_DH_FULL_UNIFIED_NULL_PUBLIC_KEY             WBECC_DH_FULL_UNIFIED_NULL_PUBLIC_KEY             // 11
#define TFIT_WBECC_DH_FULL_UNIFIED_MISSING_EPHEMERAL           WBECC_DH_FULL_UNIFIED_MISSING_EPHEMERAL           // 12
#define TFIT_WBECC_DH_FULL_UNIFIED_MISSING_STATIC              WBECC_DH_FULL_UNIFIED_MISSING_STATIC              // 13
#define TFIT_WBECC_DH_UNIFIED_NULL_PUBLIC_KEY                  WBECC_DH_UNIFIED_NULL_PUBLIC_KEY                  // 15
#define TFIT_WBECC_DH_UNIFIED_MISSING_EPHEMERAL                WBECC_DH_UNIFIED_MISSING_EPHEMERAL                // 16
#define TFIT_WBECC_DH_ONE_PASS_UNIFIED_NULL_PUBLIC_KEY         WBECC_DH_ONE_PASS_UNIFIED_NULL_PUBLIC_KEY         // 17
#define TFIT_WBECC_DH_ONE_PASS_UNIFIED_MISSING_EPHEMERAL       WBECC_DH_ONE_PASS_UNIFIED_MISSING_EPHEMERAL       // 18
#define TFIT_WBECC_DH_ONE_PASS_UNIFIED_MISSING_STATIC          WBECC_DH_ONE_PASS_UNIFIED_MISSING_STATIC          // 19
#define TFIT_WBECC_DH_ONE_PASS_NULL_PUBLIC_KEY                 WBECC_DH_ONE_PASS_NULL_PUBLIC_KEY                 // 20
#define TFIT_WBECC_DH_ONE_PASS_MISSING_EPHEMERAL               WBECC_DH_ONE_PASS_MISSING_EPHEMERAL               // 21
#define TFIT_WBECC_DH_STATIC_UNIFIED_NULL_PUBLIC_KEY           WBECC_DH_STATIC_UNIFIED_NULL_PUBLIC_KEY           // 22
#define TFIT_WBECC_DH_STATIC_UNIFIED_MISSING_STATIC            WBECC_DH_STATIC_UNIFIED_MISSING_STATIC            // 23
#define TFIT_WBECC_DH_POINT_NOT_ON_CURVE                       WBECC_DH_POINT_NOT_ON_CURVE                       // 25
#define TFIT_WBECC_DH_DOMAIN_PARAMS_INCOMPATIBLE_WITH_INSTANCE WBECC_DH_DOMAIN_PARAMS_INCOMPATIBLE_WITH_INSTANCE // 27
#define TFIT_WBECC_DH_INVALID_NUM_ENCODINGS                    WBECC_DH_INVALID_NUM_ENCODINGS                    // 28
#define TFIT_WBECC_DH_KEY_INCOMPATIBLE_WITH_INSTANCE           WBECC_DH_KEY_INCOMPATIBLE_WITH_INSTANCE           // 29
#define TFIT_WBECC_DH_STD_BUT_FST_KEY_PROVIDED                 WBECC_DH_STD_BUT_FST_KEY_PROVIDED                 // 30
#define TFIT_WBECC_DH_UNSUPPORTED_MODE                         WBECC_DH_UNSUPPORTED_MODE                         // 31
#define TFIT_WBECC_DH_EPHEMERAL_UNIFIED_NULL_PUBLIC_KEY        WBECC_DH_EPHEMERAL_UNIFIED_NULL_PUBLIC_KEY        // 32
#define TFIT_WBECC_DH_EPHEMERAL_UNIFIED_MISSING_EPHEMERAL      WBECC_DH_EPHEMERAL_UNIFIED_MISSING_EPHEMERAL      // 33
#define TFIT_WBECC_DH_MALLOC_FAILED                            WBECC_DH_MALLOC_FAILED                            // 40
#define TFIT_WBECC_DH_INVALID_PUBLIC_KEY_LENGTH 41
#define TFIT_WBECC_DH_ONE_PASS_MISSING_STATIC 42
//missing return codes 0-40 were unused or internal codes removed in 6.6 release. If these codes are reused just note
//that customers on TFIT prior to 6.6 may get codes with a different meaning.

// Internal return-codes:
#define TFIT_WBECC_DH_INTERNAL_ARITHMETIC_ERROR                WBECC_DH_INTERNAL_ARITHMETIC_ERROR                // -1
#define TFIT_WBECC_DH_CDH_ERROR                                WBECC_DH_CDH_ERROR                                // -2
#define TFIT_WBECC_DH_CLASSICAL_OXDOUT_INVALID                 WBECC_DH_CLASSICAL_OXDOUT_INVALID                 // -3
#define TFIT_WBECC_DH_FST_PREPARE_CONSTANTS_ERROR              WBECC_DH_FST_PREPARE_CONSTANTS_ERROR              // -4
#define TFIT_WBECC_DH_INTERNAL_ERROR_UNKNOWN_MODE              WBECC_DH_INTERNAL_ERROR_UNKNOWN_MODE              // -5
#define TFIT_WBECC_DH_OBFUSCATED_OUT_CONVERSION_FAILURE        WBECC_DH_OBFUSCATED_OUT_CONVERSION_FAILURE        // -6
#define TFIT_WBECC_DH_OXD_IN_PLAINTEXT                         WBECC_DH_OXD_IN_PLAINTEXT                         // -7
#define TFIT_WBECC_DH_ONE_PASS_UNSUPPORTED_MODE                WBECC_DH_ONE_PASS_UNSUPPORTED_MODE                // -8
#define TFIT_WBECC_DH_ONE_PASS_UNIFIED_UNSUPPORTED_MODE        WBECC_DH_ONE_PASS_UNIFIED_UNSUPPORTED_MODE        // -9
#define TFIT_WBECC_DH_PMULT_FAILURE                            WBECC_DH_PMULT_FAILURE                            // -10

/*
 * ECC/DSA:
 */

// enum wbecc_digest_mode:
#define TFIT_WBECC_SHA1     WBECC_SHA1     // 0
#define TFIT_WBECC_SHA2_224 WBECC_SHA2_224 // 1
#define TFIT_WBECC_SHA2_256 WBECC_SHA2_256 // 2
#define TFIT_WBECC_SHA2_384 WBECC_SHA2_384 // 3
#define TFIT_WBECC_SHA2_512 WBECC_SHA2_512 // 4

// enum wbecc_dsa_status_t:
#define TFIT_WBECC_DSA_OK                           WBECC_DSA_OK                           // 0 
#define TFIT_WBECC_DSA_GET_NONCE_DATA_FAILURE       WBECC_DSA_GET_NONCE_DATA_FAILURE       // 1
#define TFIT_WBECC_DSA_R_OUTPUT_BUFFER_TOO_SMALL    WBECC_DSA_R_OUTPUT_BUFFER_TOO_SMALL    // 2 
#define TFIT_WBECC_DSA_S_OUTPUT_BUFFER_TOO_SMALL    WBECC_DSA_S_OUTPUT_BUFFER_TOO_SMALL    // 3 
#define TFIT_WBECC_DSA_KEY_INSTANCE_ID_MISMATCH     WBECC_DSA_KEY_INSTANCE_ID_MISMATCH     // 4 
#define TFIT_WBECC_DSA_DOMAIN_INSTANCE_ID_MISMATCH  WBECC_DSA_DOMAIN_INSTANCE_ID_MISMATCH  // 5 
#define TFIT_WBECC_DSA_MALLOC_FAILED                WBECC_DSA_MALLOC_FAILED                // 6
#define TFIT_WBECC_DSA_WRONG_KEY_TYPE               WBECC_DSA_WRONG_KEY_TYPE               // 13
#define TFIT_WBECC_DSA_NULL_PARAM                   WBECC_DSA_NULL_PARAM                   // 14
#define TFIT_WBECC_DSA_R_INPUT_WRONG_SIZE           WBECC_DSA_R_INPUT_WRONG_SIZE           // 23
#define TFIT_WBECC_DSA_S_INPUT_WRONG_SIZE           WBECC_DSA_S_INPUT_WRONG_SIZE           // 24
#define TFIT_WBECC_DSA_Q_INPUT_WRONG_SIZE           WBECC_DSA_Q_INPUT_WRONG_SIZE           // 25
#define TFIT_WBECC_DSA_RESULT_INPUT_WRONG_SIZE      WBECC_DSA_RESULT_INPUT_WRONG_SIZE      // 26
#define TFIT_WBECC_DSA_SIG_VERIFY_FAILURE           WBECC_DSA_SIG_VERIFY_FAILURE           // 29
#define TFIT_WBECC_DSA_INVALID_DIGEST_LENGTH        WBECC_DSA_INVALID_DIGEST_LENGTH        // 34
#define TFIT_WBECC_DSA_DIGEST_ALREADY_EXISTS        WBECC_DSA_DIGEST_ALREADY_EXISTS        // 35
#define TFIT_WBECC_DSA_INVALID_DIGEST_MODE          WBECC_DSA_INVALID_DIGEST_MODE          // 36
//missing return codes 0-35 were unused or internal codes removed in 6.6 release. If these codes are reused just note
//that customers on TFIT prior to 6.6 may get codes with a different meaning.

// Internal return-codes:
#define TFIT_WBECC_DSA_SHA_FINAL_ERROR              WBECC_DSA_SHA_FINAL_ERROR              // -1
#define TFIT_WBECC_DSA_AFFINIFY_FAILURE             WBECC_DSA_AFFINIFY_FAILURE             // -2
#define TFIT_WBECC_DSA_ADD_FAILURE                  WBECC_DSA_ADD_FAILURE                  // -3
#define TFIT_WBECC_DSA_MULT_FAILURE                 WBECC_DSA_MULT_FAILURE                 // -4
#define TFIT_WBECC_DSA_INVERT_FAILURE               WBECC_DSA_INVERT_FAILURE               // -5
#define TFIT_WBECC_DSA_REDUCE_FAILURE               WBECC_DSA_REDUCE_FAILURE               // -6
#define TFIT_WBECC_DSA_FST_PREPARE_CONSTANTS_ERROR  WBECC_DSA_FST_PREPARE_CONSTANTS_ERROR  // -7
#define TFIT_WBECC_DSA_MONTBI_REDUCE_ERROR          WBECC_DSA_MONTBI_REDUCE_ERROR          // -8
#define TFIT_WBECC_DSA_FAILED_TO_PREP_FROM_K_AND_D  WBECC_DSA_FAILED_TO_PREP_FROM_K_AND_D  // -9
#define TFIT_WBECC_DSA_OVERSIZE_AUGMENT_FAILED      WBECC_DSA_OVERSIZE_AUGMENT_FAILED      // -10
#define TFIT_WBECC_DSA_SUB_FAILURE                  WBECC_DSA_SUB_FAILURE                  // -11
#define TFIT_WBECC_DSA_RESULT_INPUT_MISMATCH        WBECC_DSA_RESULT_INPUT_MISMATCH        // -12
#define TFIT_WBECC_DSA_PROJECTIFY_FAILURE           WBECC_DSA_PROJECTIFY_FAILURE           // -13
#define TFIT_WBECC_DSA_PMULT_FAILURE                WBECC_DSA_PMULT_FAILURE                // -14
#define TFIT_WBECC_DSA_INTERNAL_ERROR               -15

/*
 * ECC/EG:
 */

// enum wbecc_eg_status_t:
#define TFIT_WBECC_EG_OK                                       WBECC_EG_OK                                       // 0 
#define TFIT_WBECC_EG_NULL_PARAM                               WBECC_EG_NULL_PARAM                               // 1 
#define TFIT_WBECC_EG_FST_TABLE_KEY_PROVIDED                   WBECC_EG_FST_TABLE_KEY_PROVIDED                   // 5 
#define TFIT_WBECC_EG_COMMON_TABLE_KEY_PROVIDED                WBECC_EG_COMMON_TABLE_KEY_PROVIDED                // 6 
#define TFIT_WBECC_EG_KEY_INCOMPATIBLE_WITH_TBL                WBECC_EG_KEY_INCOMPATIBLE_WITH_TBL                // 7 
#define TFIT_WBECC_EG_DOMAIN_PARAMS_INCOMPATIBLE_WITH_INSTANCE WBECC_EG_DOMAIN_PARAMS_INCOMPATIBLE_WITH_INSTANCE // 8 
#define TFIT_WBECC_EG_OUTPUT_BUFFER_TOO_SMALL                  WBECC_EG_OUTPUT_BUFFER_TOO_SMALL                  // 9 
#define TFIT_WBECC_EG_EXTRA_DATA_REMAINING_IN_INTERNAL_BUFFER  WBECC_EG_EXTRA_DATA_REMAINING_IN_INTERNAL_BUFFER  // 10 
#define TFIT_WBECC_EG_GET_EPHEMERAL_DATA_FAILURE               WBECC_EG_GET_EPHEMERAL_DATA_FAILURE               // 11
#define TFIT_WBECC_EG_MALLOC_FAILED                            WBECC_EG_MALLOC_FAILED                            // 20
//missing return codes 0-20 were unused or internal codes removed in 6.6 release. If these codes are reused just note
//that customers on TFIT prior to 6.6 may get codes with a different meaning.

// Internal return-codes:
#define TFIT_WBECC_EG_INTERNAL_ARITHMETIC_ERROR                WBECC_EG_INTERNAL_ARITHMETIC_ERROR                // -1
#define TFIT_WBECC_EG_FST_PREPARE_CONSTANTS_ERROR              WBECC_EG_FST_PREPARE_CONSTANTS_ERROR              // -2
#define TFIT_WBECC_EG_PMULT_FAILURE                            WBECC_EG_PMULT_FAILURE                            // -3
#define TFIT_WBECC_EG_CLASSICAL_OXDIN_INVALID                  WBECC_EG_CLASSICAL_OXDIN_INVALID                  // -4
#define TFIT_WBECC_EG_OBFUSCATED_OXDIN_INVALID                 WBECC_EG_OBFUSCATED_OXDIN_INVALID                 // -5
#define TFIT_WBECC_EG_CLASSICAL_OXDOUT_INVALID                 WBECC_EG_CLASSICAL_OXDOUT_INVALID                 // -6
#define TFIT_WBECC_EG_OBFUSCATED_OXDOUT_INVALID                WBECC_EG_OBFUSCATED_OXDOUT_INVALID                // -7

/*
 * ECC/TK:
 */

#define TFIT_WBECC_TK_OK 0
#define TFIT_WBECC_TK_NULL_PARAM 1
#define TFIT_WBECC_TK_UNINITIALIZED_CONTEXT 2
#define TFIT_WBECC_TK_SCALAR_NOT_PREPARED 3
#define TFIT_WBECC_TK_POINT_NOT_PREPARED 4
#define TFIT_WBECC_TK_INVALID_INPUT_LENGTH 5
#define TFIT_WBECC_TK_OUTPUT_BUFFER_TOO_SMALL 6
#define TFIT_WBECC_TK_MALLOC_FAILED 7

#define TFIT_WBECC_TK_INTERNAL_ARITHMETIC_ERROR -1
#define TFIT_WBECC_TK_PREPARE_CONSTANTS_ERROR -2
#define TFIT_WBECC_TK_PREPARE_SCALAR_ERROR -3
#define TFIT_WBECC_TK_OBFUSCATED_OUT_CONVERSION_FAILURE -5

/*
 * FFC/DH:
 */

// enum ffc_dh_mode_t:
#define TFIT_WBFFC_DH_HYBRID1                 WBFFC_DH_HYBRID1                 // 0 
#define TFIT_WBFFC_DH_EPHEM                   WBFFC_DH_EPHEM                   // 1 
#define TFIT_WBFFC_DH_HYBRIDONEFLOW_INITIATOR WBFFC_DH_HYBRIDONEFLOW_INITIATOR // 2 
#define TFIT_WBFFC_DH_HYBRIDONEFLOW_RESPONDER WBFFC_DH_HYBRIDONEFLOW_RESPONDER // 3 
#define TFIT_WBFFC_DH_ONEFLOW_INITIATOR       WBFFC_DH_ONEFLOW_INITIATOR       // 4 
#define TFIT_WBFFC_DH_ONEFLOW_RESPONDER       WBFFC_DH_ONEFLOW_RESPONDER       // 5 
#define TFIT_WBFFC_DH_STATIC                  WBFFC_DH_STATIC                  // 6 

//  enum wbffc_status_t:
#define TFIT_WBFFC_OK                        WBFFC_OK                       // 0 
#define TFIT_WBFFC_INVALID_CONTEXT_OR_PARAM  WBFFC_INVALID_CONTEXT_OR_PARAM // 1 
#define TFIT_WBFFC_OUTPUT_BUFFER_TOO_SMALL   WBFFC_OUTPUT_BUFFER_TOO_SMALL  // 2 
#define TFIT_WBFFC_KEY_NOT_READY             WBFFC_KEY_NOT_READY            // 3 
#define TFIT_WBFFC_COMPUTATION_FAILURE       WBFFC_COMPUTATION_FAILURE      // 4 
#define TFIT_WBFFC_PRNG_FAILURE              WBFFC_PRNG_FAILURE             // 5 
#define TFIT_WBFFC_NOMEM                     WBFFC_NOMEM                    // 6 
#define TFIT_WBFFC_INVALID_INSTANCE          WBFFC_INVALID_INSTANCE         // 7  

/*
 * BI
 */

#define TFIT_BI_OBFUSCATED_INPUT_ERROR -3
#define TFIT_BI_OBFUSCATED_OUTPUT_ERROR -2
#define TFIT_BI_INTERNAL_ERROR -1

#define TFIT_BI_OK 0
#define TFIT_BI_NULL_PARAM 1
#define TFIT_BI_UNINITIALIZED_CONTEXT 2
#define TFIT_BI_UNINITIALIZED_NUMBER 3
#define TFIT_BI_INVALID_LENGTH 4
#define TFIT_BI_MALLOC_ERROR 5
#define TFIT_BI_DESERIALIZE_ERROR 6

/*
 * LA
 */

#define TFIT_LA_INTERNAL_ERROR -1
#define TFIT_LA_OK 0
#define TFIT_LA_NULL_PARAM 1
#define TFIT_LA_UNINITIALIZED_CONTEXT 2
#define TFIT_LA_MALLOC_ERROR 3
#define TFIT_LA_DESERIALIZE_ERROR 4
#define TFIT_LA_OUTPUT_BUFFER_TOO_SMALL 5
#define TFIT_LA_INVALID_VECTOR_LENGTH 6
#define TFIT_LA_INVALID_MATRIX_LENGTH 7


/*
 * SS
 *
 * Note: The meaning of codes -1 to 5 must match LA since an SS Combine instance uses common code with LA
 */
#define TFIT_SS_MAX_THRESHOLD 12 //currently max dimension in std_bigint_matrix.h

#define TFIT_SS_INTERNAL_ERROR -1
#define TFIT_SS_OK 0
#define TFIT_SS_NULL_PARAM 1
#define TFIT_SS_UNINITIALIZED_CONTEXT 2
#define TFIT_SS_MALLOC_ERROR 3
#define TFIT_SS_DESERIALIZE_CTX_ERROR 4
#define TFIT_SS_OUTPUT_BUFFER_TOO_SMALL 5
#define TFIT_SS_INVALID_INPUT_LEN 6
#define TFIT_SS_INVALID_THRESHOLD 7
#define TFIT_SS_DESERIALIZE_SECRET_ERROR 8
#define TFIT_SS_UNINITIALIZED_SECRET 9
#define TFIT_SS_VALIDATION_FAILURE 10
#define TFIT_SS_NONCE_FAILURE 11
#define TFIT_SS_TOO_FEW_SHARES 12
#define TFIT_SS_TOO_MANY_SHARES 13
#define TFIT_SS_INVALID_SHARES_LENGTH 14
#define TFIT_SS_REPEATED_SHARE 15


/*
 * OMA/KDF:
 */

// enum wbomakdf_status_t:
#define TFIT_WBOMAKDF_OK                                          WBOMAKDF_OK                                          // 0 
#define TFIT_WBOMAKDF_NULL_ARG                                    WBOMAKDF_NULL_ARG                                    // 1 
#define TFIT_WBOMAKDF_INVALID_INPUT_LEN                           WBOMAKDF_INVALID_INPUT_LEN                           // 2 
#define TFIT_WBOMAKDF_INVALID_OUTPUT_LEN                          WBOMAKDF_INVALID_OUTPUT_LEN                          // 3 
#define TFIT_WBOMAKDF_SLICE_UNKNOWN_ERROR                         WBOMAKDF_SLICE_UNKNOWN_ERROR                         // 4 
#define TFIT_WBOMAKDF_SLICE_NULL_ARG                              WBOMAKDF_SLICE_NULL_ARG                              // 5 
#define TFIT_WBOMAKDF_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE WBOMAKDF_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE // 6 
#define TFIT_WBOMAKDF_SLICE_INTERNAL_ERROR                        WBOMAKDF_SLICE_INTERNAL_ERROR                        // 7 
#define TFIT_WBOMAKDF_SLICE_UNSUPPORTED_WORD_SIZE                 WBOMAKDF_SLICE_UNSUPPORTED_WORD_SIZE                 // 8 
#define TFIT_WBOMAKDF_SLICE_INVALID_BYTE_ORDER_IN_WORD            WBOMAKDF_SLICE_INVALID_BYTE_ORDER_IN_WORD            // 9 
#define TFIT_WBOMAKDF_SHA_UNKNOWN_ERROR                           WBOMAKDF_SHA_UNKNOWN_ERROR                           // 10
#define TFIT_WBOMAKDF_SHA_OUTPUT_ERROR                            WBOMAKDF_SHA_OUTPUT_ERROR                            // 11
#define TFIT_WBOMAKDF_FILE_OPEN_ERROR                             WBOMAKDF_FILE_OPEN_ERROR                             // 12
#define TFIT_WBOMAKDF_FILE_SEEK_ERROR                             WBOMAKDF_FILE_SEEK_ERROR                             // 13
#define TFIT_WBOMAKDF_FILE_READ_ERROR                             WBOMAKDF_FILE_READ_ERROR                             // 14
#define TFIT_WBOMAKDF_FILE_CLOSE_ERROR                            WBOMAKDF_FILE_CLOSE_ERROR                            // 15
#define TFIT_WBOMAKDF_OUTPUTSIZE_TOO_SMALL                        WBOMAKDF_OUTPUTSIZE_TOO_SMALL                        // 16 


/*
 * RSA
 */

#define TFIT_WBRSA_SIGTYPE_SHA1 0
#define TFIT_WBRSA_SIGTYPE_SHA256 1  // deprecated, here for backwards compatibility
#define TFIT_WBRSA_SIGTYPE_SHA2_224 2
#define TFIT_WBRSA_SIGTYPE_SHA2_256 TFIT_WBRSA_SIGTYPE_SHA256
#define TFIT_WBRSA_SIGTYPE_SHA2_384 3
#define TFIT_WBRSA_SIGTYPE_SHA2_512 4

#define TFIT_WBRSA_INTERNAL_ERROR -1
#define TFIT_WBRSA_OK 0
#define TFIT_WBRSA_NULL_PARAM 1
#define TFIT_WBRSA_UNINITIALIZED_CTX 2
#define TFIT_WBRSA_VALIDATE_FAILURE 3
#define TFIT_WBRSA_DK_UNPREPARED_MODULUS 4
#define TFIT_WBRSA_DK_UNPREPARED_KEY 5
#define TFIT_WBRSA_DK_INVALID_KEY_LENGTH 6
#define TFIT_WBRSA_DK_DESERIALIZE_ERROR 7
#define TFIT_WBRSA_INIT_ERROR 8
#define TFIT_WBRSA_MALLOC_ERROR 9
#define TFIT_WBRSA_RANDOM_PROVIDER_ERROR 10
#define TFIT_WBRSA_INVALID_INPUT_LENGTH 11
#define TFIT_WBRSA_DEST_BUFFER_TOO_SMALL 12
#define TFIT_WBRSA_NO_DATA_AFTER_PADDING 13
#define TFIT_WBRSA_INVALID_PADDING 14
#define TFIT_WBRSA_INVALID_SHA_MODE 15
#define TFIT_WBRSA_INVALID_SIGNATURE_LENGTH 16
#define TFIT_WBRSA_UNALIGNED_MESSAGE 17
#define TFIT_WBRSA_SIG_VERIFY_FAILURE 18
#define TFIT_WBRSA_DM_MODULUS_TOO_SMALL 19
#define TFIT_WBRSA_DM_MODULUS_TOO_LARGE 20
#define TFIT_WBRSA_DM_INVALID_MODULUS 21
#define TFIT_WBRSA_MODULUS_TOO_SMALL_FOR_SHA_MODE 22

/*
 * SHA (Digest and HMAC):
 */

// enum wbsha_obf_t:
#define TFIT_WBSHA_CLASSICAL    WBSHA_CLASSICAL  // 0
#define TFIT_WBSHA_OBFUSCATED   WBSHA_OBFUSCATED // 1

// enum wbsha_mode_t:
#define TFIT_WBSHA_SHA1         WBSHA_SHA1         // 0
#define TFIT_WBSHA_SHA2_224     WBSHA_SHA2_224     // 1
#define TFIT_WBSHA_SHA2_256     WBSHA_SHA2_256     // 2
#define TFIT_WBSHA_SHA2_384     WBSHA_SHA2_384     // 3
#define TFIT_WBSHA_SHA2_512     WBSHA_SHA2_512     // 4

// enum wbsha_status_t:
#define TFIT_WBSHA_OK                                               WBSHA_OK                                               // 0 
#define TFIT_WBSHA_NULL_ARG                                         WBSHA_NULL_ARG                                         // 1
#define TFIT_WBSHA_DIGEST_INIT_SHA1_INITIALIZATION_FAILURE          WBSHA_DIGEST_INIT_SHA1_INITIALIZATION_FAILURE          // 5 
#define TFIT_WBSHA_DIGEST_INIT_SHA2_224_256_INITIALIZATION_FAILURE  WBSHA_DIGEST_INIT_SHA2_224_256_INITIALIZATION_FAILURE  // 6 
#define TFIT_WBSHA_DIGEST_INIT_SHA2_384_512_INITIALIZATION_FAILURE  WBSHA_DIGEST_INIT_SHA2_384_512_INITIALIZATION_FAILURE  // 7 
#define TFIT_WBSHA_DIGEST_INIT_NO_SHA_MODE_DEFINED_FOR_PREPROCESSOR WBSHA_DIGEST_INIT_NO_SHA_MODE_DEFINED_FOR_PREPROCESSOR // 8 
#define TFIT_WBSHA_DIGEST_UPDATE_SLICE_SLICE_FAILURE                WBSHA_DIGEST_UPDATE_SLICE_SLICE_FAILURE                // 11
#define TFIT_WBSHA_DIGEST_FINAL_OUTPUT_LENGTH_TOO_SMALL             WBSHA_DIGEST_FINAL_OUTPUT_LENGTH_TOO_SMALL             // 15
#define TFIT_WBSHA_DIGEST_UPDATE_REMOVE_ZEROS_INVALID_INPUT_TYPE    WBSHA_DIGEST_UPDATE_REMOVE_ZEROS_INVALID_INPUT_TYPE    // 16
//codes 17 and 18 removed 6.8 release
#define TFIT_WBSHA_HMAC_FINAL_SIGLEN_INCORRECT                      WBSHA_HMAC_FINAL_SIGLEN_INCORRECT                      // 20
#define TFIT_WBSHA_HMAC_FINAL_OUTPUT_BUFFER_TOO_SMALL               WBSHA_HMAC_FINAL_OUTPUT_BUFFER_TOO_SMALL               // 21
#define TFIT_WBSHA_HMAC_PREPARE_INCORRECT_INPUT_LEN                 WBSHA_HMAC_PREPARE_INCORRECT_INPUT_LEN                 // 23
#define TFIT_WBSHA_INPUT_TYPE_CHANGE_NOT_ON_BLOCK_BOUNDARY          WBSHA_INPUT_TYPE_CHANGE_NOT_ON_BLOCK_BOUNDARY          // 24
#define TFIT_WBSHA_DIGEST_UPDATE_REMOVE_ZEROS_AMBIGUOUS_USE_CASE    WBSHA_DIGEST_UPDATE_REMOVE_ZEROS_AMBIGUOUS_USE_CASE    // 25
#define TFIT_WBSHA_HMAC_MALLOC_FAIL                         26
#define TFIT_WBSHA_HMAC_UPDATING_FINALIZED_CTX              27
#define TFIT_WBSHA_HMAC_VALIDATE_FAILURE                    28
#define TFIT_WBSHA_HMAC_UPDATE_SLICE_SLICE_FAILURE          29
// Internal return-codes:
#define TFIT_WBSHA_HMAC_INTERNAL_ERROR                              WBSHA_HMAC_INTERNAL_ERROR                              // -1
#define TFIT_WBSHA_INTERNAL_ERROR                                   WBSHA_INTERNAL_ERROR                                   // -2
#define TFIT_WBSHA_DIGEST_INIT_OBFUSCATED_OXDOUT_INVALID            WBSHA_DIGEST_INIT_OBFUSCATED_OXDOUT_INVALID            // -3
#define TFIT_WBSHA_DIGEST_INIT_CLASSICAL_OXDOUT_INVALID             WBSHA_DIGEST_INIT_CLASSICAL_OXDOUT_INVALID             // -4 

typedef enum {
    TFIT_WBSHA_HMAC_SIGN = 0,
    TFIT_WBSHA_HMAC_VERIFY = 1,
    TFIT_WBSHA_HMAC_VERIFY_TRUNCATED = 2
} TFIT_wbsha_hmac_mode_t;

/*
 * SHA3:
 */

// enum wbsha3_mode_t:
#define TFIT_WBSHA3_MODE_224      WBSHA3_MODE_224      // 1
#define TFIT_WBSHA3_MODE_256      WBSHA3_MODE_256      // 2
#define TFIT_WBSHA3_MODE_384      WBSHA3_MODE_384      // 3
#define TFIT_WBSHA3_MODE_512      WBSHA3_MODE_512      // 4
#define TFIT_WBSHA3_MODE_SHAKE128 WBSHA3_MODE_SHAKE128 // 5
#define TFIT_WBSHA3_MODE_SHAKE256 WBSHA3_MODE_SHAKE256 // 6

// enum wbsha3_status_t:
#define TFIT_WBSHA3_OK                                              WBSHA3_OK                                               // 0
#define TFIT_WBSHA3_NULL_ARG                                        WBSHA3_NULL_ARG                                         // 1
#define TFIT_WBSHA3_INVALID_CTX                                     WBSHA3_INVALID_CTX                                      // 2
#define TFIT_WBSHA3_INVALID_SALT                                    WBSHA3_INVALID_SALT                                     // 3
#define TFIT_WBSHA3_OUTPUT_BUFFER_TOO_SMALL                         WBSHA3_OUTPUT_BUFFER_TOO_SMALL                          // 4
#define TFIT_WBSHA3_SLICE_NULL_ARG                                  WBSHA3_SLICE_NULL_ARG                                   // 51
#define TFIT_WBSHA3_SLICE_INVALID_INPUT_LEN                         WBSHA3_SLICE_INVALID_INPUT_LEN                          // 61
// Internal return-codes:
#define TFIT_WBSHA3_INTERNAL_ERROR                                  WBSHA3_INTERNAL_ERROR                                   // -1
#define TFIT_WBSHA3_SLICE_INTERNAL_ERROR                            WBSHA3_SLICE_INTERNAL_ERROR                             // -53
#define TFIT_WBSHA3_SLICE_UNKNOWN_ERROR                             WBSHA3_SLICE_UNKNOWN_ERROR                              // -50

/*
 * Slicing:
 */

// types
#define TFIT_slice_pad_side_t wbslice_pad_side_t
#define TFIT_slice_table_t wbslice_table_t
#define TFIT_slice_byte_order_t wbslice_byte_order_t

// enum wb_slice_status_t:
#define TFIT_WB_SLICE_OK                                    WB_SLICE_OK                                    // 0 
#define TFIT_WB_SLICE_NULL_ARG                              WB_SLICE_NULL_ARG                              // 1 
#define TFIT_WB_SLICE_INVALID_BYTE_ORDER                    WB_SLICE_INVALID_BYTE_ORDER                    // 2 
#define TFIT_WB_SLICE_INTERNAL_ERROR                        WB_SLICE_INTERNAL_ERROR                        // 3 
#define TFIT_WB_SLICE_FILE_OPEN_ERROR                       WB_SLICE_FILE_OPEN_ERROR                       // 4 
#define TFIT_WB_SLICE_FILE_WRITE_ERROR                      WB_SLICE_FILE_WRITE_ERROR                      // 5 
#define TFIT_WB_SLICE_FILE_CLOSE_ERROR                      WB_SLICE_FILE_CLOSE_ERROR                      // 6 
#define TFIT_WB_SLICE_FILE_SEEK_ERROR                       WB_SLICE_FILE_SEEK_ERROR                       // 7 
#define TFIT_WB_SLICE_MEMORY_ALLOCATION_ERROR               WB_SLICE_MEMORY_ALLOCATION_ERROR               // 8 
#define TFIT_WB_SLICE_UNEXPECTED_BINARY_FILE_SIZE           WB_SLICE_UNEXPECTED_BINARY_FILE_SIZE           // 9 
#define TFIT_WB_SLICE_UNSUPPORTED_WORD_SIZE                 WB_SLICE_UNSUPPORTED_WORD_SIZE                 // 10
#define TFIT_WB_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE WB_SLICE_FULL_INPUT_LEN_NOT_WORD_SIZE_MULTIPLE // 11
#define TFIT_WB_SLICE_BAD_MAGIC                             WB_SLICE_BAD_MAGIC                             // 12
#define TFIT_WB_SLICE_UNSUPPORTED_VERSION                   WB_SLICE_UNSUPPORTED_VERSION                   // 13
#define TFIT_WB_SLICE_INVALID_BYTE_ORDER_IN_WORD            WB_SLICE_INVALID_BYTE_ORDER_IN_WORD            // 14
#define TFIT_WB_SLICE_BYTES_OUT_OF_RANGE                    WB_SLICE_BYTES_OUT_OF_RANGE                    // 15
#define TFIT_WB_SLICE_UNALIGNED_BUFFER                      WB_SLICE_UNALIGNED_BUFFER                      // 16
     
// enum wb_word_order_t:
#define TFIT_WBSLICE_FIRST_WORD_AT_HIGHEST_ADDRESS WBSLICE_FIRST_WORD_AT_HIGHEST_ADDRESS // 0
#define TFIT_WBSLICE_FIRST_WORD_AT_LOWEST_ADDRESS  WBSLICE_FIRST_WORD_AT_LOWEST_ADDRESS  // 1

// enum wb_pad_side_t:
#define TFIT_WBSLICE_ZERO_PAD_AT_HIGHEST_ADDRESS WBSLICE_ZERO_PAD_AT_HIGHEST_ADDRESS // 0
#define TFIT_WBSLICE_ZERO_PAD_AT_LOWEST_ADDRESS  WBSLICE_ZERO_PAD_AT_LOWEST_ADDRESS  // 1

// Slicing APIs:
#define TFIT_create_slice_order wbslice_create_order
#define TFIT_slice              wb_slice


/*
 * XLAT:
 */

// enum wbxlat_status:                      
#define TFIT_WBXLAT_OK                      WBXLAT_OK                      // 0 
#define TFIT_WBXLAT_MISMATCH_INPUT_FORM     WBXLAT_MISMATCH_INPUT_FORM     // 1 
#define TFIT_WBXLAT_MISMATCH_XOR_FORM       WBXLAT_MISMATCH_XOR_FORM       // 2 
#define TFIT_WBXLAT_MISMATCH_OUTPUT_FORM    WBXLAT_MISMATCH_OUTPUT_FORM    // 3 
#define TFIT_WBXLAT_MISMATCH_DIRECTION      WBXLAT_MISMATCH_DIRECTION      // 4 
#define TFIT_WBXLAT_MISMATCH_BLOB           WBXLAT_MISMATCH_BLOB           // 5 
#define TFIT_WBXLAT_UNALIGNED               WBXLAT_UNALIGNED               // 6 
#define TFIT_WBXLAT_OVERFLOW                WBXLAT_OVERFLOW                // 7 
#define TFIT_WBXLAT_INTERNAL_ERROR          WBXLAT_INTERNAL_ERROR          // 8 
#define TFIT_WBXLAT_FUNC_ERROR              WBXLAT_FUNC_ERROR              // 9 
#define TFIT_WBXLAT_NULL_ARG                WBXLAT_NULL_ARG                // 10
#define TFIT_WBXLAT_UPDATING_FINALIZED_CTX  WBXLAT_UPDATING_FINALIZED_CTX  // 11
#define TFIT_WBXLAT_MEMORY_ALLOCATION_FAIL  WBXLAT_MEMORY_ALLOCATION_FAIL  // 12
#define TFIT_WBXLAT_INVALID_MSG_SIZE        WBXLAT_INVALID_MSG_SIZE        // 13
#define TFIT_WBXLAT_OUTPUT_BUFFER_TOO_SMALL WBXLAT_OUTPUT_BUFFER_TOO_SMALL // 14
#define TFIT_WBXLAT_KEY_BUFFER_TOO_SHORT    WBXLAT_KEY_BUFFER_TOO_SHORT    // 15

#endif /* __TFIT_H__ */
