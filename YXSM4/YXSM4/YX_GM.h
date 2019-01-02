//
//  YX_GM.h
//  YXSM4
//
//  Created by 邵刚 on 2018/10/26.
//  Copyright © 2018年 邵刚. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YX_GM : NSObject



/**
 singletone mode
 */
+ (instancetype)shared;

#pragma mark --- SM4 Algorithm ---

/**
 random iv for sm4
 */
- (NSString *)randomSM4IV __attribute((deprecated(("not use anymore!"))));

/**
 random key for sm4
 */
- (NSString *)randomSM4Key;

/**
 encrypt plain data for sm4
 
 @param plainData to be encrypted
 @param key for sm4 cbc-mode
 @return encrypt result, null for error
 */
- (NSData * _Nullable)sm4_encryptData:(NSData *)plainData withCipherKey:(NSString *)key NS_AVAILABLE_IOS(8_0);

/**
 decrypt cipher data for sm4
 
 @param cipherData to be decrypted
 @param key for sm4 cbc-mode
 @return decrypt result, null for error
 */
- (NSData * _Nullable)sm4_decryptData:(NSData *)cipherData withCipherKey:(NSString *)key NS_AVAILABLE_IOS(8_0);

/**
 encrypt plain file for sm4-ecb
 
 @param srcPath for origin file path
 @param desPath for destnation file path
 @param key for sm4-ecb
 @param completion for call back, null error if success
 */
- (void)sm4_encryptFile:(NSString *)srcPath withDestFilePath:(NSString *)desPath withCipherKey:(NSString *)key withCompletion:(void(^_Nullable)(NSError*_Nullable err))completion;

/**
 decrypt cipher file for sm4-ecb
 
 @param srcPath for cipher file path
 @param desPath for plain file path
 @param key fir sm4-ecb
 @param completion for call back, null error if success
 */
- (void)sm4_decryptFile:(NSString *)srcPath withDestFilePath:(NSString *)desPath withCipherKey:(NSString *)key withCompletion:(void(^_Nullable)(NSError*_Nullable err))completion;

/**
 encrypt plain stream byte for sm4-ecb
 
 @param inBytes plain bytes
 @param inLen plain byte len
 @param outBytes out cipher bytes
 @param outLen out length
 @param key cipher key
 */
- (void)sm4_encryptStream:(const Byte *)inBytes inLength:(unsigned int)inLen withOutput:(Byte *)outBytes outLength:(unsigned int *)outLen withCipherKey:(NSString *)key;

/**
 decrypt cipher stream byte for sm4-ecb
 
 @param inBytes cipher bytes
 @param inLen cipher byte len
 @param outBytes out plain bytes
 @param outLen out plain byte len
 @param key cipher key
 */
- (void)sm4_decryptStream:(const Byte *)inBytes  inLength:(unsigned int)inLen withOutput:(Byte *)outBytes outLength:(unsigned int *)outLen withCipherKey:(NSString *)key;


/**
 hash data for sm3
 
 @param plainData for input plain data
 @return hash result, null for error
 */
- (NSData * _Nullable)sm3_hashWithPainData:(NSData *)plainData;


@end

NS_ASSUME_NONNULL_END
