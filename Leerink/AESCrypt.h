//
//  AESCrypt.h
//  Leerink
//
//  Created by Bibhuti on 17/02/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESCrypt : NSObject

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;
+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password;

+ (NSData *)encryptNSData:(NSData *)message password:(NSString *)password;
+ (NSData *)decryptNSData:(NSData *)base64EncodedString password:(NSString *)password;

@end
