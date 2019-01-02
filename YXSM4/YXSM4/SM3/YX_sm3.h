//
//  YX_sm3.h
//  YXSM4
//
//  Created by 邵刚 on 2018/10/26.
//  Copyright © 2018年 邵刚. All rights reserved.
//

#ifndef YX_sm3_h
#define YX_sm3_h

/**
 * \brief          SM3 context structure
 */
typedef struct
{
    unsigned long total[2];     /*!< number of bytes processed  */
    unsigned long state[8];     /*!< intermediate digest state  */
    unsigned char buffer[64];   /*!< data block being processed */
    
    unsigned char ipad[64];     /*!< HMAC: inner padding        */
    unsigned char opad[64];     /*!< HMAC: outer padding        */
    
}
YX_sm3_context;

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     * \brief          SM3 context setup
     *
     * \param ctx      context to be initialized
     */
    void YX_sm3_starts( YX_sm3_context *ctx );
    
    /**
     * \brief          SM3 process buffer
     *
     * \param ctx      SM3 context
     * \param input    buffer holding the  data
     * \param ilen     length of the input data
     */
    void YX_sm3_update( YX_sm3_context *ctx, unsigned char *input, int ilen );
    
    /**
     * \brief          SM3 final digest
     *
     * \param ctx      SM3 context
     */
    void YX_sm3_finish( YX_sm3_context *ctx, unsigned char output[32] );
    
    /**
     * \brief          Output = SM3( input buffer )
     *
     * \param input    buffer holding the  data
     * \param ilen     length of the input data
     * \param output   SM3 checksum result
     */
    void YX_sm3( unsigned char *input, int ilen,
                     unsigned char output[32]);
    
    /**
     * \brief          Output = SM3( file contents )
     *
     * \param path     input file name
     * \param output   SM3 checksum result
     *
     * \return         0 if successful, 1 if fopen failed,
     *                 or 2 if fread failed
     */
    int YX_sm3_file( char *path, unsigned char output[32] );
    
    /**
     * \brief          SM3 HMAC context setup
     *
     * \param ctx      HMAC context to be initialized
     * \param key      HMAC secret key
     * \param keylen   length of the HMAC key
     */
    void YX_sm3_hmac_starts( YX_sm3_context *ctx, unsigned char *key, int keylen);
    
    /**
     * \brief          SM3 HMAC process buffer
     *
     * \param ctx      HMAC context
     * \param input    buffer holding the  data
     * \param ilen     length of the input data
     */
    void YX_sm3_hmac_update( YX_sm3_context *ctx, unsigned char *input, int ilen );
    
    /**
     * \brief          SM3 HMAC final digest
     *
     * \param ctx      HMAC context
     * \param output   SM3 HMAC checksum result
     */
    void YX_sm3_hmac_finish( YX_sm3_context *ctx, unsigned char output[32] );
    
    /**
     * \brief          Output = HMAC-SM3( hmac key, input buffer )
     *
     * \param key      HMAC secret key
     * \param keylen   length of the HMAC key
     * \param input    buffer holding the  data
     * \param ilen     length of the input data
     * \param output   HMAC-SM3 result
     */
    void YX_sm3_hmac( unsigned char *key, int keylen,
                          unsigned char *input, int ilen,
                          unsigned char output[32] );
    
    
#ifdef __cplusplus
}
#endif

#endif /* YX_sm3_h */
