/*
 LBCocoaSecurity  1.1

 Created by Kelp on 12/5/12.
 Copyright (c) 2012 Kelp http://kelp.phate.org/
 MIT License
 
 LBCocoaSecurity is core. It provides AES encrypt, AES decrypt, Hash(MD5, HmacMD5, SHA1~SHA512, HmacSHA1~HmacSHA512) messages.
*/

#import <Foundation/Foundation.h>
#import <Foundation/NSException.h>


#pragma mark - LBCocoaSecurityResult
@interface LBCocoaSecurityResult : NSObject

@property (strong, nonatomic, readonly) NSData *data;
@property (strong, nonatomic, readonly) NSString *utf8String;
@property (strong, nonatomic, readonly) NSString *hex;
@property (strong, nonatomic, readonly) NSString *hexLower;
@property (strong, nonatomic, readonly) NSString *base64;

- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length;

@end


#pragma mark - LBCocoaSecurity
@interface LBCocoaSecurity : NSObject
#pragma mark - AES Encrypt
+ (LBCocoaSecurityResult *)aesEncrypt:(NSString *)data key:(NSString *)key;
+ (LBCocoaSecurityResult *)aesEncrypt:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv;
+ (LBCocoaSecurityResult *)aesEncrypt:(NSString *)data key:(NSData *)key iv:(NSData *)iv;
+ (LBCocoaSecurityResult *)aesEncryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;
#pragma mark AES Decrypt
+ (LBCocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSString *)key;
+ (LBCocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv;
+ (LBCocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSData *)key iv:(NSData *)iv;
+ (LBCocoaSecurityResult *)aesDecryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;

#pragma mark - MD5
+ (LBCocoaSecurityResult *)md5:(NSString *)hashString;
+ (LBCocoaSecurityResult *)md5WithData:(NSData *)hashData;
#pragma mark HMAC-MD5
+ (LBCocoaSecurityResult *)hmacMd5:(NSString *)hashString hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacMd5WithData:(NSData *)hashData hmacKey:(NSString *)key;

#pragma mark - SHA
+ (LBCocoaSecurityResult *)sha1:(NSString *)hashString;
+ (LBCocoaSecurityResult *)sha1WithData:(NSData *)hashData;
+ (LBCocoaSecurityResult *)sha224:(NSString *)hashString;
+ (LBCocoaSecurityResult *)sha224WithData:(NSData *)hashData;
+ (LBCocoaSecurityResult *)sha256:(NSString *)hashString;
+ (LBCocoaSecurityResult *)sha256WithData:(NSData *)hashData;
+ (LBCocoaSecurityResult *)sha384:(NSString *)hashString;
+ (LBCocoaSecurityResult *)sha384WithData:(NSData *)hashData;
+ (LBCocoaSecurityResult *)sha512:(NSString *)hashString;
+ (LBCocoaSecurityResult *)sha512WithData:(NSData *)hashData;
#pragma mark HMAC-SHA
+ (LBCocoaSecurityResult *)hmacSha1:(NSString *)hashString hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha1WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha224:(NSString *)hashString hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha224WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha256:(NSString *)hashString hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha256WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha384:(NSString *)hashString hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha384WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha512:(NSString *)hashString hmacKey:(NSString *)key;
+ (LBCocoaSecurityResult *)hmacSha512WithData:(NSData *)hashData hmacKey:(NSString *)key;
@end


#pragma mark - LBCocoaSecurityEncoder
@interface LBCocoaSecurityEncoder : NSObject
- (NSString *)base64:(NSData *)data;
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower;
@end


#pragma mark - LBCocoaSecurityDecoder
@interface LBCocoaSecurityDecoder : NSObject
- (NSData *)base64:(NSString *)data;
- (NSData *)hex:(NSString *)data;
@end
