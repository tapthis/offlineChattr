//
//  NSString+AES.h
//  AESEncryptionDemo

//

#import <Foundation/Foundation.h>
#import "NSData+AES.h"


@interface NSString (AES)
- (NSString *)AES128EncryptWithKey:(NSString *)key;
- (NSString *)AES128DecryptWithKey:(NSString *)key;
@end
