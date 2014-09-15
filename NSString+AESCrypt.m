//
//  NSString+AESCrypt.m
//  offlineChattr
//
//  Created by Patrik Boras on 03/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import "NSString+AESCrypt.h"

@implementation NSString (AESCrypt)

- (NSString *)AES128EncryptWithKey:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES128EncryptWithKey:key];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)AES128DecryptWithKey:(NSString *)key
{
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData AES128DecryptWithKey:key];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}

@end
