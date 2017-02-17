//
//  NSString+Base64.h
//  Leerink
//
//  Created by Bibhuti on 17/02/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (Base64Additions)

+ (NSString *)base64StringFromData:(NSData *)data length:(NSUInteger)length;

@end
