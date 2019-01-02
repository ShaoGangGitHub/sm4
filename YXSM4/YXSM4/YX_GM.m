//
//  YX_GM.m
//  YXSM4
//
//  Created by 邵刚 on 2018/10/26.
//  Copyright © 2018年 邵刚. All rights reserved.
//

#import "YX_GM.h"
#import <CommonCrypto/CommonCrypto.h>
#import <YXSM4/YX_sm4.h>
#import <YXSM4/YX_sm3.h>


static unsigned int const SM4_BLOCK_SIZE    =   16;

/** vector for aes/sm4 **/
static NSString * const IV_SM4              =   @"sm4ivectorcodec1";

@interface YX_GM ()

@end

static YX_GM * instance = nil;

@implementation YX_GM


+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark --- util kit methods ---

- (NSString *)randomString4Length:(unsigned int)len {
    if (len<=0) {
        return nil;
    }
    NSString *sourceString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *result = [[NSMutableString alloc] init];
    //srand((unsigned)time(0));
    unsigned c_len = (unsigned)sourceString.length;
    for (int i = 0; i < len; i++){
        //unsigned index = rand() % [sourceString length];
        unsigned index = arc4random() % c_len;
        NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
        [result appendString:s];
    }
    return result.copy;
    //    return @"yxkns5yLcdQ4EE6l";
}

- (NSString *)string2Hex:(NSString *)plain {
    NSData *myD = [plain dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}

#pragma mark --- SM4 Algorithm ---

- (NSString *)randomSM4IV {
    return [self randomString4Length:SM4_BLOCK_SIZE];
}

- (NSString *)randomSM4Key {
    return [self randomString4Length:SM4_BLOCK_SIZE];//32bit for 256-mode
}

- (NSData * _Nullable)sm4_encryptData:(NSData *)plainInData withCipherKey:(NSString *)key {
    if (plainInData == nil) {
        NSLog(@"got an empty data!");
        return plainInData;
    }
    if (key.length != SM4_BLOCK_SIZE) {
        NSLog(@"got a bad sm4 key!");
        return nil;
    }
    
    //a.对明文数据进行填充来保证位数是16的倍数
    int plainInDataLength = (int)plainInData.length;
    //  p是需要填充的数据也是填充的位数
    int p = SM4_BLOCK_SIZE - plainInDataLength % SM4_BLOCK_SIZE;
    unsigned char plainInChar[plainInDataLength + p];
    memcpy(plainInChar, plainInData.bytes, plainInDataLength);
    //  进行数据填充
    for (int i = 0; i < p; i++) {
        plainInChar[plainInDataLength + i] =  p;
    }
    
    //b.验证一下填充后的char[]是不是最开始的明文数据
    //    NSLog(@"plainInData=%@",plainInData);
    //    NSData *data = [[NSData alloc]initWithBytes:plainInChar length:sizeof(plainInChar)-p];
    //    NSLog(@"data=%@",data);
    //    NSLog(@"填充后的char[]转成NSString=%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    
    
    //4.对plainInChar加密，由于源代码中加解密是放在一起的，现在在sm4test.c中新添加两个方法把加密和解密分开,由于计算length总出问题，所以直接把length作为参数传进去
    
    //5.调用刚才添加的方法加密
    //定义输出密文的变量
    unsigned char cipherOutChar[plainInDataLength + p];
    unsigned char iv[16]   = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0xfe,0xdc,0xba,0x98,0x76,0x54,0x32,0x10};
    //unsigned char key[16]   = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0xfe,0xdc,0xba,0x98,0x76,0x54,0x32,0x10};
    //const unsigned char * key_char = [key UTF8String];
    const char* utf8Key = [key UTF8String];
    size_t len = strlen(utf8Key) + 1;
    unsigned char sm4Key[len];
    memcpy(sm4Key, utf8Key, len);
    YX_sm4_context ctx;
    //设置上下文和密钥
    YX_sm4_setkey_enc(&ctx,sm4Key);
    //加密
    YX_sm4_crypt_ecb(&ctx,SM4_ENCRYPT,plainInDataLength + p,plainInChar,cipherOutChar);
    //    sm4_crypt_cbc(&ctx, SM4_ENCRYPT, plainInDataLength + p, iv, plainInChar, cipherOutChar);
    //testEncodejiami(plainInDataLength + p, plainInChar, cipherOutChar);
    //对加密的数据输出
    NSData *cipherTextData =  [[NSData alloc]initWithBytes:cipherOutChar length:sizeof(cipherOutChar)];
    //    NSLog(@"密文NSData=%@",cipherTextData);
    //    NSLog(@"密文转成NSString=%@",[[NSString alloc]initWithData:cipherTextData encoding:NSUTF8StringEncoding]);
    return cipherTextData;
}

- (NSData * _Nullable)sm4_decryptData:(NSData *)cipherData withCipherKey:(NSString *)key {
    if (cipherData == nil) {
        NSLog(@"got an empty data!");
        return cipherData;
    }
    if (key.length != SM4_BLOCK_SIZE) {
        NSLog(@"got a bad sm4 key!");
        return nil;
    }
    unsigned char iv[16]   = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0xfe,0xdc,0xba,0x98,0x76,0x54,0x32,0x10};
    const char* utf8Key = [key UTF8String];
    size_t len = strlen(utf8Key) + 1;
    unsigned char sm4Key[len];
    memcpy(sm4Key, utf8Key, len);
    
    //6将cipherTextData作为输入，调用第4步的解密方法，进行解密
    //将data拷贝到字符数组中
    unsigned char cipherTextChar[cipherData.length];
    memcpy(cipherTextChar, cipherData.bytes, cipherData.length);
    //调用解密方法，输出是明文plainOutChar
    unsigned char plainOutChar[cipherData.length];
    //testDecodejiemi(cipherTextData.length, cipherTextChar, plainOutChar);
    //设置上下文和密钥
    YX_sm4_context ctx;
    YX_sm4_setkey_dec(&ctx,sm4Key);
    //    sm4_crypt_cbc(&ctx, SM4_DECRYPT, (int)cipherData.length, iv, cipherTextChar, plainOutChar);
    YX_sm4_crypt_ecb(&ctx, SM4_DECRYPT, (int)cipherData.length, cipherTextChar, plainOutChar);
    
    //由于明文是填充过的，解密时候要去填充，去填充要在解密后才可以，在解密前是去不了的
    int p2 = plainOutChar[sizeof(plainOutChar) - 1];//p2是填充的数据，也是填充的长度
    int outLength = (int)cipherData.length-p2;//明文的长度
    //去掉填充得到明文
    unsigned char plainOutWithoutPadding[outLength];
    memcpy(plainOutWithoutPadding, plainOutChar, outLength);
    //明文转成NSData 再转成NSString打印
    NSData *outData = [[NSData alloc]initWithBytes:plainOutWithoutPadding length:sizeof(plainOutWithoutPadding)];
    
    return outData;
}

static inline NSError * assembleErrorWithDomain(NSString *domain) {
    return [NSError errorWithDomain:domain code:-1 userInfo:nil];
}

long file_len(FILE *file) {
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    return size;
}

#define FILE_MAX_CRYPTO_SIZE 1024 * 1024 * 10 //10M
#define FILE_BLOCK_SIZE 128 //16K
#define VERSION_PREFIX_LEN 4 //前四个字节 携带版本信息
- (void)sm4_encryptFile:(NSString *)srcPath withDestFilePath:(NSString *)desPath withCipherKey:(NSString *)key withCompletion:(void (^ _Nullable)(NSError * _Nullable))completion {
    NSAssert(srcPath.length != 0, @"could not read an empty path!");
    NSAssert(desPath.length != 0, @"could not open an empty path!");
    NSAssert(key.length == SM4_BLOCK_SIZE, @"got a bad key for sm4-ecb!");
    //whether file exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:srcPath]) {
        if (completion) {
            NSError *err = assembleErrorWithDomain(@"could not read an empty file!");
            completion(err);
        }
        return;
    }
    //Byte version[VERSION_PREFIX_LEN] = {1,1,1,1};
    NSError *err = nil;
    FILE *in_f = NULL, *out_f = NULL;
    long in_len = 0, file_length = 0;
    
    const char* utf8Key = [key UTF8String];
    size_t utf_len = strlen(utf8Key) + 1;
    unsigned char sm4Key[utf_len];
    memcpy(sm4Key, utf8Key, utf_len);
    
    //open in_file and out_file
    const char * in_file = [srcPath UTF8String];
    const char * out_file = [desPath UTF8String];
    in_f = fopen(in_file, "rb");
    if (in_f == NULL) {
        err = assembleErrorWithDomain(@"failed to open in file!");
        goto encrypt_file_end;
    }
    out_f = fopen(out_file, "wb");
    if (out_f == NULL) {
        err = assembleErrorWithDomain(@"failed to open out file!");
        goto encrypt_file_end;
    }
    //detect file length
    file_length = file_len(in_f);
    if (file_length < 0) {
        err = assembleErrorWithDomain([NSString stringWithFormat:@"failed to detect file length:%ld", file_length]);
        goto encrypt_file_end;
    }
    //read block caches
    Byte in[FILE_BLOCK_SIZE + SM4_BLOCK_SIZE];
    Byte out[FILE_BLOCK_SIZE + SM4_BLOCK_SIZE];
    size_t count = 0, read_len = 0;
    size_t len, w;
    int block_size = SM4_BLOCK_SIZE;
    
    //write version to dest file
    //    w = fwrite(version, sizeof(Byte), VERSION_PREFIX_LEN, out_f);
    //    if (w != VERSION_PREFIX_LEN) {
    //        err = assembleErrorWithDomain(@"write version to dest file error!");
    //        goto encrypt_file_end;
    //    }
    
    //read cycle
    in_len = file_length < FILE_MAX_CRYPTO_SIZE ? file_length : FILE_MAX_CRYPTO_SIZE;//最多加密定义的大小
    while (1) {
        len = fread(in, sizeof(Byte), FILE_BLOCK_SIZE, in_f);
        read_len += len;
        
        //if block size not divide by SM4_BLOCK_SIZE and there is more data left, error accoured
        if (len != FILE_BLOCK_SIZE && len != in_len - count) {
            err = assembleErrorWithDomain(@"read file error");
            fclose(out_f); remove(out_file);
            goto encrypt_file_end;
        }
        //last block
        if (len == in_len - count) {
            Byte padding = (len + block_size) / block_size * block_size - len;
            memset(in + len, padding, padding);
            len += padding;
        }
        //encrypt block
        YX_sm4_context ctx;
        YX_sm4_setkey_enc(&ctx, sm4Key);
        YX_sm4_crypt_ecb(&ctx, SM4_ENCRYPT, (int)len, in, out);
        //write to out file
        w = fwrite(out, sizeof(Byte), len, out_f);
        if (w != len) {
            err = assembleErrorWithDomain([NSString stringWithFormat:@"write out file error:%zu", w]);
            goto encrypt_file_end;
        }
        
        count += len;
        
        if (count >= in_len) {
            break;
        }
    }
    
    //fixed length when there file size > max_len(10M)
    while (read_len < file_length) {
        len = fread(in, sizeof(Byte), FILE_BLOCK_SIZE, in_f);
        read_len += len;
        //if block size not divide by SM4_BLOCK_SIZE and there is more data left, error accoured
        if (len != FILE_BLOCK_SIZE && read_len != file_length) {
            err = assembleErrorWithDomain(@"read file error");
            fclose(out_f); remove(out_file);
            goto encrypt_file_end;
        }
        //write to out file
        w = fwrite(in, sizeof(Byte), len, out_f);
        if (w != len) {
            err = assembleErrorWithDomain([NSString stringWithFormat:@"write out file error:%zu", w]);
            goto encrypt_file_end;
        }
        
        count += len;
    }
    
    count += VERSION_PREFIX_LEN;
    //*out_len = count;修正文件最后大小
    
encrypt_file_end:
    if (in_f) fclose(in_f);
    if (out_f) fclose(out_f);
    
    if (completion) {
        completion(err);
    }
}

- (void)sm4_decryptFile:(NSString *)srcPath withDestFilePath:(NSString *)desPath withCipherKey:(NSString *)key withCompletion:(void (^ _Nullable)(NSError * _Nullable))completion {
    NSAssert(srcPath.length != 0, @"could not read an empty path!");
    NSAssert(desPath.length != 0, @"could not open an empty path!");
    NSAssert(key.length == SM4_BLOCK_SIZE, @"got a bad key for sm4-ecb!");
    //whether file exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:srcPath]) {
        if (completion) {
            NSError *err = [NSError errorWithDomain:@"could not read an empty file!" code:-1 userInfo:nil];
            completion(err);
        }
        return;
    }
    
    //Byte version[VERSION_PREFIX_LEN];
    NSError *err = nil;
    FILE *in_f = NULL, *out_f = NULL;
    long in_len = 0, file_length = 0;
    
    const char* utf8Key = [key UTF8String];
    size_t utf_len = strlen(utf8Key) + 1;
    unsigned char sm4Key[utf_len];
    memcpy(sm4Key, utf8Key, utf_len);
    
    //open in_file and out_file
    const char * in_file = [srcPath UTF8String];
    const char * out_file = [desPath UTF8String];
    in_f = fopen(in_file, "rb");
    if (in_f == NULL) {
        err = assembleErrorWithDomain(@"failed to open in file!");
        goto decrypt_file_end;
    }
    out_f = fopen(out_file, "wb");
    if (out_f == NULL) {
        err = assembleErrorWithDomain(@"failed to open out file!");
        goto decrypt_file_end;
    }
    //detect file length
    file_length = file_len(in_f);
    if (file_length < 0) {
        err = assembleErrorWithDomain([NSString stringWithFormat:@"failed to detect file length:%ld", file_length]);
        goto decrypt_file_end;
    }
    if (file_length < VERSION_PREFIX_LEN) {
        err = assembleErrorWithDomain(@"ciphertext too short!");
        goto decrypt_file_end;
    }
    //read block caches
    Byte in[FILE_BLOCK_SIZE];
    Byte out[FILE_BLOCK_SIZE];
    size_t count = 0, read_len = 0;
    size_t len, block_len;
    size_t w;
    size_t len_tmp;
    
    //    w = fread(version, sizeof(Byte), VERSION_PREFIX_LEN, in_f);
    //    if (w != VERSION_PREFIX_LEN) {
    //        err = assembleErrorWithDomain(@"read in_file error");
    //        goto decrypt_file_end;
    //    }
    
    //start decrypt
    int block_size = SM4_BLOCK_SIZE;
    in_len = file_length < (FILE_MAX_CRYPTO_SIZE + VERSION_PREFIX_LEN + block_size)?file_length:(FILE_MAX_CRYPTO_SIZE+VERSION_PREFIX_LEN+block_size);
    if ((in_len - VERSION_PREFIX_LEN) % block_size != 0) {
        err = assembleErrorWithDomain([NSString stringWithFormat:@"illegal in_file length: %ld.\n", in_len]);
        goto decrypt_file_end;
    }
    while (1) {
        block_len = (in_len - read_len) < FILE_BLOCK_SIZE?(in_len-read_len):FILE_BLOCK_SIZE;
        len = fread(in, sizeof(Byte), block_len, in_f);
        read_len += len;
        if (len != FILE_BLOCK_SIZE && len != in_len - count - VERSION_PREFIX_LEN) {
            fclose(out_f);remove(out_file);
            err = assembleErrorWithDomain([NSString stringWithFormat:@"read file error: %zu.\n", len]);
            goto decrypt_file_end;
        }
        //decrypt block
        YX_sm4_context ctx;
        YX_sm4_setkey_dec(&ctx, sm4Key);
        YX_sm4_crypt_ecb(&ctx, SM4_DECRYPT, (int)len, in, out);
        
        len_tmp = len;
        if (len == in_len - VERSION_PREFIX_LEN - count) {
            Byte padding = out[len - 1];
            len_tmp -= padding;
        }
        //write to out file
        w = fwrite(out, sizeof(Byte), len_tmp, out_f);
        if (w != len_tmp) {
            err = assembleErrorWithDomain([NSString stringWithFormat:@"write out_file error: %zu.\n", w]);
            goto decrypt_file_end;
        }
        if (count + len >= in_len - VERSION_PREFIX_LEN) {
            count += len_tmp;
            break;
        }
        
        count += len;
    }
    
    //fixed while origin file size > fileMax(10M)
    if (file_length > FILE_MAX_CRYPTO_SIZE + VERSION_PREFIX_LEN + block_size) {
        while (read_len < file_length) {
            len = fread(in, sizeof(Byte), FILE_BLOCK_SIZE, in_f);
            read_len += len;
            if (len != FILE_BLOCK_SIZE && read_len != file_length) {
                err = assembleErrorWithDomain([NSString stringWithFormat:@"read file error: %zu.\n", len]);
                goto decrypt_file_end;
            }
            //write to out file
            w = fwrite(in, sizeof(Byte), len, out_f);
            if (w != len) {
                err = assembleErrorWithDomain([NSString stringWithFormat:@"write out_file error: %zu.\n", w]);
                goto decrypt_file_end;
            }
            count += len;
        }
    }
    
    //*out_len = count;
    
decrypt_file_end:
    if (in_f) fclose(in_f);
    if (out_f) fclose(out_f);
    
    if (completion) {
        completion(err);
    }
}
- (void)sm4_encryptStream:(const Byte *)inBytes inLength:(unsigned int)inLen withOutput:(Byte *)outBytes outLength:(unsigned int *)outLen withCipherKey:(NSString *)key {
    NSAssert(key.length != 0, @"could not use an empty cipher key!");
    //prepare for key
    const char* utf8Key = [key UTF8String];
    size_t utf_len = strlen(utf8Key) + 1;
    unsigned char sm4Key[utf_len];
    memcpy(sm4Key, utf8Key, utf_len);
    //block size
    int block_size = SM4_BLOCK_SIZE;
    size_t len = inLen/block_size * block_size;
    unsigned char *input = malloc(sizeof(Byte) * len);
    memcpy(input, inBytes, len);
    //encrypt with sm4-ecb
    YX_sm4_context ctx;
    YX_sm4_setkey_enc(&ctx, sm4Key);
    YX_sm4_crypt_ecb(&ctx, SM4_ENCRYPT, (int)len, input, outBytes + VERSION_PREFIX_LEN);
    //done
    memcpy(outBytes + VERSION_PREFIX_LEN + len, inBytes + len, inLen - len);
    *outLen = inLen + VERSION_PREFIX_LEN;
    free(input);
}

- (void)sm4_decryptStream:(const Byte *)inBytes inLength:(unsigned int)inLen withOutput:(Byte *)outBytes outLength:(unsigned int *)outLen withCipherKey:(NSString *)key {
    NSAssert(key.length != 0, @"could not use an empty cipher key!");
    //prepare for key
    const char* utf8Key = [key UTF8String];
    size_t utf_len = strlen(utf8Key) + 1;
    unsigned char sm4Key[utf_len];
    memcpy(sm4Key, utf8Key, utf_len);
    //block size
    int block_size = SM4_BLOCK_SIZE;
    size_t len = (inLen - VERSION_PREFIX_LEN)/block_size * block_size;
    Byte *out_tmp = malloc(sizeof(Byte) * len);
    //decrypt
    YX_sm4_context ctx;
    YX_sm4_setkey_dec(&ctx, sm4Key);
    YX_sm4_crypt_ecb(&ctx, SM4_DECRYPT, (int)len, (unsigned char *)inBytes + VERSION_PREFIX_LEN, out_tmp);
    //done
    memcpy(outBytes, out_tmp, len);
    memcpy(outBytes + len, inBytes + VERSION_PREFIX_LEN + len, inLen - VERSION_PREFIX_LEN - len);
    *outLen = inLen - VERSION_PREFIX_LEN;
    free(out_tmp);
}

#pragma mark --- SM3 Algorithm ---

- (NSData *_Nullable)sm3_hashWithPainData:(NSData *)plainData {
    if (plainData == nil) {
        NSLog(@"got an empty input!");
        return plainData;
    }
    int plainLen = (int)plainData.length;
    unsigned char plainInChar[plainLen];
    memcpy(plainInChar, plainData.bytes, plainLen);
    
    //init hash output
    int outputLen = 32;
    unsigned char output[outputLen];
    YX_sm3(plainInChar, plainLen, output);
    return [NSData dataWithBytes:output length:outputLen];
}





@end

