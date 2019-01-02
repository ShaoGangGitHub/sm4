//
//  YX_sm4.h
//  PBGMService
//
//  Created by 邵刚 on 2018/10/26.
//  Copyright © 2018年 nanhujiaju. All rights reserved.
//

#ifndef YX_sm4_h
#define YX_sm4_h


#define SM4_ENCRYPT     1
#define SM4_DECRYPT     0

/**
 * \brief          SM4 context structure
 */
typedef struct
{
    int mode;                   /*!<  encrypt/decrypt   */
    unsigned long sk[32];       /*!<  SM4 subkeys       */
}
YX_sm4_context;

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     * \brief          SM4 key schedule (128-bit, encryption)
     *
     * \param ctx      SM4 context to be initialized
     * \param key      16-byte secret key
     */
    void YX_sm4_setkey_enc( YX_sm4_context *ctx, unsigned char key[16] );
    
    /**
     * \brief          SM4 key schedule (128-bit, decryption)
     *
     * \param ctx      SM4 context to be initialized
     * \param key      16-byte secret key
     */
    void YX_sm4_setkey_dec( YX_sm4_context *ctx, unsigned char key[16] );
    
    /**
     * \brief          SM4-ECB block encryption/decryption
     * \param ctx      SM4 context
     * \param mode     SM4_ENCRYPT or SM4_DECRYPT
     * \param length   length of the input data
     * \param input    input block
     * \param output   output block
     */
    void YX_sm4_crypt_ecb( YX_sm4_context *ctx,
                       int mode,
                       int length,
                       unsigned char *input,
                       unsigned char *output);
    
    /**
     * \brief          SM4-CBC buffer encryption/decryption
     * \param ctx      SM4 context
     * \param mode     SM4_ENCRYPT or SM4_DECRYPT
     * \param length   length of the input data
     * \param iv       initialization vector (updated after use)
     * \param input    buffer holding the input data
     * \param output   buffer holding the output data
     */
    void YX_sm4_crypt_cbc( YX_sm4_context *ctx,
                       int mode,
                       int length,
                       unsigned char iv[16],
                       unsigned char *input,
                       unsigned char *output );
    
#ifdef __cplusplus
}
#endif


#endif /* YX_sm4_h */
