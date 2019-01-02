//
//  NSString+YX_GM_String.h
//  YXSM4
//
//  Created by 邵刚 on 2018/10/26.
//  Copyright © 2018年 邵刚. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (YX_GM_String)

/**
 sm4加密，加密方式ecb

 @param key 16位随机串
 @return 加密后的base64字符串
 */
- (NSString *)sm4WithKey:(NSString *)key;

/**
 sm3加密
 
 @return sm3加密后的base64字符串
 */
- (NSString *)sm3;

/**
 sm3加密
 
 @return sm3加密 data String
 */
- (NSString *)sm3ForData;

@end

NS_ASSUME_NONNULL_END
